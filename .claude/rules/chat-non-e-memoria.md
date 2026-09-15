# La chat non è memoria: tutto ciò che si scrive in sessione si scrive anche su disco

> Regola modulare, da caricare sempre. Nasce da una direttiva d'uso del 2026-09-09 in un progetto istanziato da questo template, ed è generale: non riguarda lo stile della risposta, che è materia di `interaction-style.md`, ma la sua persistenza.

## Il principio

Ciò che l'agente scrive in chat non esiste per il progetto. Una sessione finisce, una compattazione riscrive, un crash cade a metà di un commit: ogni misura, ogni correzione e ogni decisione che viva soltanto nella risposta è già perduta nel momento in cui viene scritta. La regola è quindi che nessun contenuto sostanziale resti nella sola conversazione, e che l'aggiornamento dei file avvenga nel medesimo giro di lavoro in cui il contenuto nasce, non alla fine della sessione quando il contesto è pieno e l'attenzione bassa.

Ne segue una prescrizione operativa semplice. Se una risposta contiene un numero misurato, quel numero va anche in un documento generato o in una nota autorata. Se contiene una correzione a un'affermazione precedente, la correzione va nel work log e, se cambia lo stato, nella scheda o nell'indice. Se contiene una decisione dell'utente, va nel registro delle decisioni come ADR. Se contiene un lavoro rimandato, una verifica aperta o del materiale atteso, va nel registro delle pendenze. E se contiene una fonte con ciò su cui è autorevole, va nel registro delle fonti.

## Che cosa non conta come persistenza

Non basta che il contenuto sia deducibile da un file: deve esservi scritto. Una misura che sta soltanto nell'output di uno strumento non è persistita, perché nessuno rilancia uno strumento per ricordare un numero; va nel documento che quello strumento genera. Un ragionamento che sta soltanto nel messaggio dell'agente non è persistito nemmeno quando è corretto, e la prova è che la sessione successiva lo rifarebbe da capo con esito magari diverso.

Non conta neppure un aggiornamento differito. La direttiva dice di aggiornare ogni volta, e la ragione è che il debito di scrittura si comporta come il debito di lettura: cresce in silenzio e si paga quando conviene meno. Un giro di lavoro che produce un risultato e non lo scrive lascia il progetto in uno stato in cui la chat e il disco divergono, che è precisamente lo stato che un sistema di memoria esiste per evitare.

## Il vincolo che resta intatto

La regola non autorizza a toccare `context/` e `memory/` di propria iniziativa quando l'utente non lo ha chiesto: quel vincolo resta, e la sua ragione è che il versionamento della memoria stia sotto controllo umano. Le due cose convivono così: l'agente scrive sempre i documenti di conoscenza, cioè studi, censimenti, referenze e registro delle fonti, e per la memoria e le schede propone il delta e lo applica quando l'utente lo chiede, salvo che la richiesta di aggiornare sia già stata data in forma generale.

## Il presidio

Alla fine di ogni giro di lavoro sostanziale l'agente dichiara, in una riga, quali file ha scritto. È il modo in cui la regola si verifica invece di essere solo dichiarata: se quella riga non c'è, il contenuto è rimasto in chat.
