# fix-typography

Tre strumenti che attuano meccanicamente le convenzioni tipografiche della regola `interaction-style.md`: gli accenti scritti con l'apostrofo diventano accenti veri secondo la grammatica italiana, quelli mancanti del tutto vengono ripristinati dove la parola senza accento non esiste, e i trattini lunghi diventano trattini brevi. Sono complementari a `md-unwrap`, che attua la convenzione della riga sorgente unica, e nascono dalla stessa constatazione: una convenzione dichiarata e non verificata non viene rispettata.

## Perché serve

La regola diceva già che i trattini lunghi non si usano, e non diceva nulla sugli accenti perché nessuno si era accorto del problema. In pratica, nel repository del template convivevano tre grafie della stessa parola: i due documenti normativi usavano gli accenti veri, molti file usavano l'apostrofo posticcio, e alcuni non mettevano l'accento affatto. Sul primo repository che ha adottato il sistema le occorrenze erano oltre seimila, e i trattini lunghi oltre quattrocento. Non era una scelta di stile: era un residuo che si propagava da un progetto all'altro attraverso questi stessi template.

## Che cosa fa `fix-accents.py`

Converte le forme con apostrofo nelle forme accentate, distinguendo l'accento acuto dal grave secondo la grammatica: acuto nei composti di *che*, *ne* e *se*, cioè perché, poiché, benché, né, sé, e in poche altre come poté e ventitré; grave nel verbo essere e su tutte le vocali *a*, *i*, *o*, *u* in fine di parola, dove l'italiano non conosce l'accento acuto.

Quest'ultima è una regola e non una lista, ed è ciò che rende lo strumento manutenibile: le decine di parole che finiscono in *-ità*, *-età*, *-erà* si convertono per suffisso, senza doverle enumerare. Le uscite in *e* restano a lista, perché lì il segno dipende dalla parola.

La parte che conta davvero, però, è ciò che lo strumento **non** tocca, perché una sostituzione ingenua distruggerebbe testo corretto.

Gli apostrofi che non sono accenti mancanti restano intatti. Il caso di scuola è `un po'`, troncamento di *poco*, che con l'accento grave diventa uno degli errori più diffusi in italiano; nella stessa categoria stanno gli imperativi tronchi `fa'`, `va'`, `sta'`, `di'`, e l'elisione, dove `dell'area` non è candidata perché all'apostrofo segue una lettera.

La forma `da'` è dichiarata ambigua e non viene convertita: è l'indicativo di *dare* con l'accento grave, oppure il suo imperativo con l'apostrofo, e le due si distinguono solo dal senso della frase. Lo strumento le elenca e offre il flag `--da-indicativo` per convertirle dopo che un umano ha letto i contesti.

Nei file Markdown salta i blocchi di codice recintati e i code span in linea, perché là un apostrofo può essere sintassi. Nei file Python la prudenza è maggiore e merita di essere spiegata, perché il rischio è reale e si è manifestato durante lo sviluppo: in una stringa come `'meta'` l'apostrofo di chiusura è indistinguibile da un accento, e una prima versione dello strumento ha trasformato quella stringa in `'metà`, rompendola. La difesa non è un elenco di eccezioni ma un riconoscitore più stretto: una parola preceduta da apostrofo non è candidata, perché in un file di codice quello è un delimitatore. Con quella garanzia la conversione lavora anche nei commenti, nelle stringhe di documentazione e nelle stringhe a doppi apici, e lascia intatte le chiavi citate fra apici singoli.

Lo strumento esclude infine il proprio sorgente, perché i suoi casi di prova contengono di proposito le sequenze che cerca, e una corsa su se stesso li altererebbe. È accaduto due volte, e la difesa è strutturale invece che mnemonica.

## Che cosa fa `fix-missing-accents.py`

È il terzo strumento e affronta il caso più insidioso: le parole a cui l'accento manca del tutto, senza apostrofo né alcun altro segno che le denunci. Nel materiale ereditato si leggono frasi come «è già progettato», «densità sopra completezza», «più di un estratto», dove nulla distingue a prima vista un errore da una parola corretta. Il primo strumento non le vede, perché cerca l'apostrofo.

La strategia è l'unica onesta possibile, e va detta invece di lasciarla scoprire: si converte soltanto dove la forma senza accento non è una parola italiana. *Più* senza accento non esiste, quindi può solo essere *più*; lo stesso per *già*, *così*, *può*, *perché*, *cioè*, e per le uscite in *-ità* e *-età* che senza accento non significano nulla. Su queste la conversione è sicura per costruzione, non per euristica. Tutto il resto si conta e si riporta con `--ambigue`, e la decisione resta a chi conosce il testo.

Sulla *e* isolata lo strumento converte solo tre contesti in cui la congiunzione è grammaticalmente impossibile: dopo una negazione, che pretende un verbo; dopo la congiunzione *ed*, che non può precederne un'altra; e dopo il relativo *che*. Un quarto criterio, basato sulla parola che segue, è stato tentato e rimosso, e vale registrare perché: l'idea era che la *e* seguita da un aggettivo predicativo dovesse essere il verbo, dato che una congiunzione non regge un aggettivo isolato. Nel corpus reale quell'assunto cade sulle coordinazioni, dove il secondo membro è proprio un aggettivo: in «documentato byte per byte e verificato» la congiunzione coordina due participi, e convertirla cambia il significato della frase. Il difetto è strutturale e non si aggiusta accorciando la lista, perché distinguere i due casi richiede di sapere se ciò che precede la *e* sia un soggetto o un altro aggettivo. Quella distinzione non si fa con un'espressione regolare, e uno strumento che non può decidere non decide.

Fra le forme che sembravano sicure e non lo sono, il gruppo da conoscere è quello dei sostantivi in *-ità* che coincidono con la terza persona di un verbo in *-itare*: `eredita`, `necessita`, `facilita`, `mobilita`, `nobilita`, `abilita`. Nei testi di questi progetti sono quasi sempre il verbo, come in «un pezzo che si eredita adottando una libreria», e accentarli sarebbe un errore. Fuori da quel gruppo restano `onesta`, che è anche l'aggettivo femminile, e `unita`, che è anche il participio di unire.

## Che cosa fa `fix-dashes.py`

Normalizza cinque segni distinti che a video somigliano a un trattino: il trattino em, il trattino en, la barra orizzontale, il trattino da cifre e il segno meno matematico. Quest'ultimo è il più insidioso in un testo tecnico, perché è un operatore e non punteggiatura, e chi copia una formula che lo contiene ottiene un carattere che nessun compilatore accetta.

Le esclusioni si dichiarano in `dashes-exclude.txt`, una per riga con il motivo dopo un cancelletto, e un'esclusione senza motivo viene rifiutata. Il file arriva con due voci che è utile conoscere perché sono istruttive. La prima è lo strumento `docx-to-docs`, la cui tabella di sostituzione contiene proprio quei caratteri per poterli rimuovere dai documenti convertiti: normalizzarli lì lo renderebbe cieco. La seconda è un documento di riferimento copiato da una fonte esterna, che per la regola di stile mantiene la formattazione originale.

## Come si installa

Si copiano i tre script e il file delle esclusioni in `tools/` del progetto. Non hanno dipendenze oltre alla libreria standard.

```
cp .claude/templates/fix-typography/tools/fix-accents.py tools/
cp .claude/templates/fix-typography/tools/fix-missing-accents.py tools/
cp .claude/templates/fix-typography/tools/fix-dashes.py tools/
cp .claude/templates/fix-typography/tools/dashes-exclude.txt tools/
```

## Come si usa

La prima corsa su un progetto esistente si fa sempre in tre passaggi, e l'ordine non è formale: serve a non applicare cinquemila sostituzioni prima di aver guardato che cosa lo strumento non ha capito.

```
python tools/fix-accents.py --autotest
python tools/fix-accents.py --check --ext .md,.tex,.py .
python tools/fix-accents.py --residui --ext .md,.tex,.py .
```

L'autotest verifica che lo strumento funzioni in questo ambiente. Il controllo a vuoto dice quante sostituzioni farebbe e quali forme ha riconosciuto. L'elenco dei residui dice quali forme con apostrofo non sono in nessuna lista né coperte dalla regola: sono le parole di altre lingue, che vanno lasciate, e le eventuali forme italiane da aggiungere. Solo dopo aver letto i residui, e i contesti degli ambigui, si applica.

```
python tools/fix-accents.py --da-indicativo --ext .md,.tex,.py .
python tools/fix-missing-accents.py .
python tools/fix-dashes.py --ext .md,.tex,.py .
```

Il secondo strumento ha una sua fase di lettura che vale la pena non saltare, perché produce l'unico elenco che nessuno strumento potrà mai risolvere.

```
python tools/fix-missing-accents.py --autotest
python tools/fix-missing-accents.py --check .
python tools/fix-missing-accents.py --ambigue .
```

L'ultimo comando elenca le forme che restano indecidibili, con il motivo accanto a ciascuna: la congiunzione contro il verbo essere, l'articolo contro l'avverbio di luogo, il pronome contro l'affermazione. Su un corpus di media grandezza sono migliaia di occorrenze, e la sola cosa sensata è leggerle quando si rilegge il testo per altre ragioni, non tutte in una volta.

## Verifiche dopo l'applicazione

Su un progetto che ha del codice, le due verifiche che contano sono che i file Python compilino ancora e che la suite di test passi. Su un progetto che ha del LaTeX, che il documento compili. Sono controlli banali e vanno fatti comunque, perché una sostituzione massiva su centinaia di file non si lascia al caso.

```
python -c "import ast,glob; [ast.parse(open(f,'rb').read().decode('utf-8')) for f in glob.glob('tools/*.py')]"
```

## Adattamenti di dominio

Lo strumento si estende quando il progetto ha un linguaggio in cui l'apostrofo ha un significato proprio, e il caso reale già incontrato vale come esempio del genere di attenzione che serve. In un progetto di notazione musicale con LilyPond l'apostrofo dopo il nome di una nota ne alza l'ottava, quindi `e'` è un Mi e non una *e* accentata, e la riga `\relative e' { ... }` sarebbe stata distrutta. La difesa aggiunta là non è un elenco di eccezioni ma il salto dei blocchi in cui la notazione vive, cioè gli ambienti `lilypond`, le righe che invocano un comando musicale e i file `.ly` per intero.

Il criterio generale, se il caso si ripresenta, è quello: si salta la regione, non si elencano i simboli. Un elenco di eccezioni invecchia, una regione dichiarata no.
