# Proposta: ricevute riproducibili per operazioni a passi

**Stato.** Proposta di sviluppo richiesta dal proprietario il 27 ottobre 2026. Non implementata, non attiva e fuori dal catalogo dei pacchetti. Il dettaglio vive qui; il filone degli strumenti agentici e il suo indice ne registrano la pendenza. Nessuna nuova regola caricata all'avvio.

## Il problema concreto

Un resoconto del terminale perde il collegamento fra il codice inviato a un host, i parametri, la risposta e lo stato che ne consegue. Un output conservato senza lo script non permette di capire che cosa sia stato davvero eseguito. Uno script conservato senza stdout, stderr ed esito non permette di distinguere una prova riuscita da un'interruzione a metà. Una ricevuta positiva di sola lettura, infine, non prova che la successiva operazione mutante sia stata eseguita.

La proposta nasce da un'esigenza operativa di ricostruzione a micro-passaggi. Il contributo specifico non è il promemoria generico di salvare i log: è il contratto che separa autorizzazione, comando, trasporto, verifica dello stato e conclusione consentita. Un errore SSH o un timeout possono lasciare effetti già avvenuti sul remoto; il solo codice di uscita del client non autorizza a registrare «nessuna modifica» o a ripetere il comando.

## Destinatario e costo

Il futuro pacchetto si propone ai progetti che eseguono manutenzioni remote, procedure sperimentali o operazioni in più passi con approvazioni, oppure che devono consegnare una prova riproducibile del lavoro. Non si impone a ogni comando di sviluppo locale. Il settore è strumenti di lavoro degli agenti, con un collegamento operativo a macchine e continuità.

La specifica iniziale privilegia un adattatore locale senza servizi esterni, con dati dentro il progetto e interfaccia portabile Windows/Linux. Dipendenze, licenza, dimensionamento, retention e rimozione restano da progettare e provare prima del catalogo. Non si introduce un demone o un magazzino globale per raccogliere le esecuzioni.

## Contratto della ricevuta

Ogni esecuzione ottiene un identificatore nuovo e una cartella che non sovrascrive prove precedenti. Il manifest registra versione del protocollo, riferimento Git quando disponibile, hash dei sorgenti non riservati, ambiente di destinazione espresso con un alias, modalità di sola verifica oppure azione, autorizzazione ricevuta e suo perimetro.

Ogni passo registra argv approvati e redatti, input non riservato o suo riferimento verificabile, istanti UTC di avvio e termine, durata monotona quando disponibile, codice di uscita, stdout, stderr e hash dei file conservati. Uno script inviato via stdin conserva anche i byte esatti quando non contengono segreti. Non si ricostruisce a posteriori un comando che non era stato registrato.

Le osservazioni prima e dopo sono un elenco esplicito di campi pertinenti all'effetto promesso. Un esito tecnico del comando e il confronto dello stato sono campi distinti. Lo stato dei passi prevede non eseguito, tentato, riuscito, fallito ed effetto remoto ignoto; il rapporto non converte automaticamente un errore di trasporto in assenza di effetti. Le ricevute interrotte restano leggibili e l'esito finale dichiara quali passi sono stati completati.

Il modello distingue almeno questi livelli, senza usare un solo booleano per tutti:

| Livello | Che cosa dimostra |
|---|---|
| Autorizzato | L'operatore ha approvato quel preciso perimetro; non dimostra esecuzione |
| Tentato | Il comando è stato avviato; non dimostra completamento remoto |
| Trasporto concluso | Il client ha ricevuto un esito; non sostituisce il confronto dello stato |
| Verificato | Le osservazioni pertinenti sostengono la conclusione dichiarata |
| Ignoto | Mancano elementi per stabilire gli effetti; occorre ispezionare prima di ripetere |

## Segreti, dati e conservazione

Si parte da una lista consentita di comandi, parametri e osservazioni, redigendo i valori prima di scrivere qualsiasi log. Non si catturano alla cieca ambiente, argomenti dei processi, configurazioni, chiavi, token o corpi di risposta con dati personali. Un hash di un segreto non è anonimizzazione: gli input riservati non vanno salvati o trasformati in hash per aggirare il vincolo.

Quando un input riservato è indispensabile, la ricevuta documenta il metodo autorizzato di fornitura e ciò che non è riproducibile senza una credenziale nuova, senza esportare il valore. Anche stderr e gli errori di validazione fanno parte del perimetro da redigere. I controlli negativi devono usare segreti sintetici e cercarli in tutti gli artefatti prodotti.

La cartella di prova è privata e ignorata da Git. Versionati restano il protocollo, i programmi e il riepilogo adatto al repository; conservazione e backup delle prove sono espliciti. Un manifest a hash controlla la corrispondenza dei byte, non è una firma o una certificazione di assenza di compromissione. La versione da condividere può contenere un sottoinsieme motivato delle prove, mantenendo il collegamento alle originali interne.

## Autorizzazione e ripresa

L'autorizzazione a una copia non include installazione, riavvio, produzione o ripristino. Il requisito di poter accettare una breve interruzione non è l'autorizzazione al comando che la provoca. Commit, push e deploy seguono comunque il controllo umano del progetto; il pacchetto non aggiunge una via automatica per eseguirli.

Una directory già presente, un hash diverso o uno stato cambiato fermano l'operazione. La ripresa collega la ricevuta nuova alla precedente ed esplicita quali controlli riusa; non ripete automaticamente un passo mutante. La riproducibilità è la possibilità di ricostruire e valutare il lavoro, non il permesso di rigiocarlo contro un servizio attivo.

## Prove necessarie prima del rilascio del pacchetto

Il collaudo deve includere almeno un successo reale su un ambiente isolato, un errore di comando con stderr conservato, un timeout dopo un effetto remoto già avvenuto, un hash alterato che ferma le mutazioni e una ripresa che conserva entrambe le ricevute. Deve distinguere una verifica riuscita senza azione dall'azione riuscita, rilevare variazioni dello stato protetto e rifiutare un'autorizzazione relativa a un altro ambiente.

La prova dei segreti deve dimostrare l'assenza di valori sintetici in argv, stdin conservato, stdout, stderr, eccezioni e manifest. La portabilità deve provare newline, encoding, percorsi con spazi e caratteri non ASCII su Windows e Linux. Un rapporto renderizzato a partire dalle ricevute deve mantenere visibili errore, ignoto, passi riusati e punti non eseguiti; un report sempre verde non soddisfa il contratto.

## Passo di sviluppo successivo

Definire uno schema minimo della ricevuta e un adattatore di esecuzione con controlli prima/dopo iniettati dal progetto, poi provarlo su un piccolo servizio isolato con fault injection. Solo dopo misurare costo e benefici, scegliere il trigger del gate, documentare installazione e rimozione e valutare l'ingresso in catalogo. Questa consegna registra la proposta: non implementa o distribuisce il pacchetto.

**Esito del 27 ottobre.** Proposta generalizzata senza nomi di progetti, domini o valori di accesso; indice del filone e punto di ripresa aggiornati. Nessuna modifica alle capacità attive o ai file già in stage di altre lavorazioni. Version control manuale.
