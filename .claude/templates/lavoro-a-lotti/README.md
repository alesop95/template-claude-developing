# Pacchetto opzionale: lavoro-a-lotti

> Impianto per svolgere un lavoro **piu' grande di qualunque finestra di sessione** su un corpus di molti elementi, in modo riprendibile fra sessioni e fra giorni, e per distribuirlo su piu' flotte di agenti con serbatoi di quota indipendenti. Non e' un orchestratore e non lancia processi: e' il **contratto** che rende il lavoro interrompibile, e il presidio che impedisce di ricominciare da capo.

## Cosa risolve

Il caso e' sempre lo stesso e ha sempre la stessa forma: una **mappatura** su molti elementi piu' una **aggregazione** finale. Parsing retroattivo di centinaia di file, studio preparatorio a un refactoring esteso, ingestione di un corpus documentale da mettere in relazione.

Il problema che si osserva e' che la sessione finisce a meta'. E la diagnosi istintiva, cioe' "ho lanciato troppi agenti in parallelo", **e' sbagliata**, come mostra l'aritmetica.

Assunto dichiarato: una passata per elemento che legge, ragiona e scrive un esito costa dell'ordine di qualche migliaio di token. Su trecento elementi si arriva **all'ordine del milione di token** per la sola mappatura, prima di qualunque aggregazione. Nessuna finestra di una sessione interattiva contiene quel lavoro, ne' in parallelo ne' in sequenza.

> **Il parallelismo non consuma piu' token per elemento: consuma gli stessi token in meta' tempo.** Non e' la causa dell'esaurimento, e' l'acceleratore. Una misurazione pubblicata su un refactor di oltre trecento file riporta il limite raggiunto in circa quindici minuti in parallelo contro trenta in sequenza, sullo stesso piano e sullo stesso lavoro.

Ne segue che la domanda utile non e' "come parallelizzo senza bruciare" ma **"come faccio un lavoro che non entra in una finestra"**, e la risposta e' in quattro leve, in ordine di efficacia, dove il parallelismo arriva ultimo.

**Togliere elementi.** Molta mappatura e' deterministica: estrazione, normalizzazione, filtro, deduplicazione per hash. Solo gli elementi che richiedono *giudizio* devono vedere un modello. Portare N da trecento a trenta vale piu' di qualunque ottimizzazione sui trecento, ed e' l'unica leva che cambia l'ordine di grandezza.

**Rendere il lavoro riprendibile.** Se la finestra finisce all'elemento 180, ricominciare da capo non e' un fastidio: e' la ragione per cui questi lavori non si finiscono mai. E' il pezzo che questo pacchetto fornisce, ed e' quello che nessuno degli strumenti esaminati offre.

**Instradare su serbatoi indipendenti.** La mappatura ripetitiva va su una flotta di agenti con la propria quota; l'aggregazione resta sulla flotta principale. I due consumi non si sommano sullo stesso limite.

**Solo a questo punto, parallelizzare**, che comprime il tempo di attesa dentro una finestra senza cambiare il totale.

## Perche' un registro e non un orchestratore

Gli orchestratori esistono, sono maturi e risolvono un problema diverso: l'**isolamento del filesystem**, perche' piu' agenti sullo stesso repository si pestano i piedi con rami e modifiche non salvate. Danno la leva e non il criterio, e nessuno di essi risponde a *quando convenga* ne' a *come si riprende*.

Questo pacchetto quindi **non li sostituisce e non li duplica**: si compone con essi, e funziona anche senza. Il passaggio di consegne fra agenti e' un file nel repository, il che porta tre proprieta' che nessun orchestratore offre.

E' **agnostico rispetto all'agente**: funziona con qualunque agente da terminale, con due agenti diversi insieme, e a mano.

E' **ispezionabile**: il passaggio di consegne si legge, non e' un canale opaco fra processi.

E' **durevole**: sopravvive alla chiusura di tutto, perche' e' su disco e nel controllo di versione.

## Prima di costruire: che cosa il sistema produce gia'

Applicazione diretta della sezione 20 del sistema di progetto. Prima di aggiungere un registro si guarda che cosa esiste, e in questo sistema esiste parecchio.

| Gia' disponibile | Copre | Questo pacchetto |
|---|---|---|
| `doc-ingest` | manifest a content-hash che **non riconverte l'invariato**: ripresa della fase di **conversione** | non la duplica; la presuppone |
| `ccusage` | misura reale del consumo per sessione, modello e progetto | non stima a occhio: la stima di costo si tara su quella misura |
| `rules/token-economy.md` | disclosure progressiva a tre livelli, caricamento on-demand | e' la riduzione del costo **per elemento**, e resta la prima leva |
| controllo di versione | i commit sono gia' un registro di cio' che e' stato fatto | il registro copre il lavoro **prima** che diventi commit |

Ne segue il perimetro esatto: **il registro copre la fase di ragionamento per elemento**, cioe' l'unica che nessuno degli strumenti sopra traccia.

## Il registro

Un file JSONL nel livello privato del progetto, una riga per elemento.

```json
{
  "id": "<identificativo stabile dell'elemento, tipicamente il percorso relativo>",
  "hash": "<digest del contenuto al momento della presa in carico>",
  "stato": "da-fare | in-corso | fatto | saltato | errore",
  "agente": "<etichetta della flotta che lo ha lavorato>",
  "artefatto": "<percorso relativo dell'esito prodotto, se previsto>",
  "nota": "<una riga sul perche', obbligatoria per saltato e errore>",
  "aggiornato": "<data e ora>"
}
```

Tre scelte meritano la spiegazione, perche' sono quelle su cui un registro fatto male fallisce.

**L'identificativo e' stabile e il contenuto e' hashato.** Senza l'hash, un elemento modificato dopo essere stato marcato come fatto resta fatto per sempre, e il registro diventa una bugia che si consolida. Con l'hash, una modifica lo riporta automaticamente da fare.

**Lo stato ammette `saltato` come esito legittimo**, distinto da `errore`, e in entrambi i casi la nota e' obbligatoria. Un registro che ammette solo fatto e non-fatto costringe a mentire sugli elementi che non andavano lavorati, ed e' cosi' che si perde la distinzione fra "non serviva" e "non ci sono riuscito".

**Il campo dell'agente esiste** perche' senza di esso, a valle, non si sa piu' quale flotta ha prodotto cosa, e la prima anomalia di qualita' non e' attribuibile.

## Il presidio, e perche' non guarda lo stato

> **Sezione 19 del sistema di progetto: un controllo che dipende da cio' che deve controllare non e' un controllo.**

Il campo `stato` lo scrive **l'agente che deve superare il controllo**. Un agente che si dichiara `fatto` senza aver prodotto nulla supera qualunque verifica basata su quel campo, e lo fa senza malafede: basta che abbia interpretato male il mandato, o che sia stato interrotto dopo aver scritto lo stato e prima di scrivere l'esito.

Il presidio quindi **non consulta lo stato dichiarato: consulta l'artefatto**. Un elemento conta come concluso se e solo se il file di esito esiste, non e' vuoto, e ha la forma dichiarata. Dove non e' previsto un artefatto, il lavoro va ridisegnato perche' ne produca uno: **un esito che non lascia traccia non e' verificabile**, e un lavoro non verificabile non e' riprendibile.

Il presidio dichiara anche che cosa **non** copre, come prescrive la sezione 17. Distingue la presenza dall'assenza, **non il buono dal mediocre**: sa dire che un esito esiste ed e' ben formato, non che sia corretto. Credere il contrario produce fiducia in una copertura che non esiste.

E dichiara la propria discordanza come dato utile: un elemento `fatto` senza artefatto non e' un dettaglio da sistemare in silenzio, e' la prova che qualcosa nel mandato non ha funzionato, e va guardato prima di rilanciare.

## La regola di instradamento fra flotte

Vale quando sulla macchina esistono **due o piu' flotte di agenti con quote indipendenti**. Il criterio e' la natura del compito, non la sua difficolta'.

| Fase | Dove | Perche' |
|---|---|---|
| **Mappatura** per elemento: leggere, estrarre, classificare, riassumere | flotta secondaria | ripetitiva, mandato stretto, esito breve e verificabile; e' il volume |
| **Aggregazione**: mettere in relazione, decidere, scrivere | flotta principale | richiede il contesto d'insieme, che e' precisamente cio' che non va sprecato |
| **Progettazione** del lotto e revisione degli esiti | flotta principale | e' la parte che decide se il resto ha senso |

La flotta secondaria **non deve conoscere l'aggregazione**, e la principale **non deve leggere gli elementi grezzi**: legge gli artefatti. E' la stessa disciplina del subagent come firewall di contesto, applicata fra processi diversi invece che dentro uno solo.

## Il cancello: quando NON usare questo pacchetto

Il settore dell'orchestrazione ha gia' un trigger quantitativo dichiarato nel catalogo: **sotto le tre sessioni o i tre rami paralleli costa piu' di quanto renda.** Qui se ne aggiunge uno specifico, e va posto come domanda prima di cominciare.

**Quanti elementi, e quanto costa uno?** Se il prodotto sta comodamente in una finestra, il registro e' burocrazia: si fa il lavoro e basta.

**Quanti elementi richiedono davvero giudizio?** Se la risposta e' "tutti", quasi sempre non e' stata cercata la parte deterministica. Si torna alla prima leva.

**Esiste un artefatto per elemento?** Se no, il lavoro non e' verificabile e il registro non puo' presidiarlo. Si ridisegna il lavoro, non si adotta il registro.

## Mappa di istanziazione

| Dal pacchetto | Nel progetto | Tracciato |
|---|---|---|
| `registro.esempio.jsonl` | `_notes/registro-<lavoro>.jsonl` | no, e' stato di lavoro |
| `tools/registro.py` | `tools/registro.py` | si' |
| la regola di instradamento | `.claude/rules/lavoro-a-lotti.md`, dichiarata fra le regole caricate | si' |

Il registro sta nel livello privato perche' e' **stato**, non conoscenza: cambia a ogni elemento lavorato e sporcherebbe la storia. Lo strumento e la regola sono invece impianto, e si versionano.

## Come si usa, passo per passo

Si dichiara il lavoro e si genera il registro dagli elementi del corpus. Si esegue il presidio in sola lettura per vedere quanti elementi ci sono e quale sia lo stato. Si stima il costo, con il consumo misurato invece che assunto. Si lavora un lotto, fermandosi prima della fine della finestra invece che dopo. Si esegue di nuovo il presidio, che confronta artefatti e stati e segnala le discordanze. Si riprende, anche il giorno dopo, e il registro dice da dove.

## La forma del mandato, che decide se il registro serve a qualcosa

Lezione del primo pilota su un corpus reale, ed e' costata l'intero lotto. Il mandato dato all'agente era: *leggi i primi dieci elementi da fare, poi scrivi le dieci sintesi, poi aggiorna le dieci righe*.

L'agente ha letto i dieci sorgenti, ha annunciato *"ora preparo le sintesi e aggiorno il registro"*, e ha chiuso il turno. **Zero artefatti, zero righe aggiornate, quindicimila token spesi in letture da rifare.** Nessun errore, nessuna sandbox, nessun permesso negato: semplicemente un turno finito prima della fase di scrittura.

Il difetto non e' dell'agente ma del mandato, e ha una forma precisa: **tutto il progresso viveva nel turno**. Un lotto strutturato come "leggi tutto, poi scrivi tutto" ha un unico punto in cui il lavoro diventa durevole, e se il turno finisce prima di quel punto non resta niente. E' esattamente cio' che il registro esiste per impedire, sabotato dalla forma della richiesta.

> **La regola: il mandato deve rendere durevole ogni singolo elemento, non il lotto.** Si legge un elemento, si scrive il suo artefatto, si aggiorna la sua riga, e solo allora si passa al successivo. Un'interruzione in qualunque punto lascia gli elementi gia' chiusi sul disco e il registro coerente con essi.

La verifica che la forma sia giusta e' una domanda sola: **se il turno finisse adesso, quanto lavoro sopravviverebbe?** Se la risposta dipende da quanti elementi mancano alla fine del lotto, la forma e' sbagliata.

Ne discende anche la dimensione del lotto. Non serve tenerla piccola per prudenza: con la forma corretta un lotto grande e' sicuro quanto uno piccolo, perche' ogni elemento e' gia' un punto di ripresa. La dimensione si sceglie sul tempo di attesa accettabile, non sul rischio.

## Il costo per elemento, misurato

Primo lotto reale su un corpus documentale, dieci elementi da circa nove kilobyte l'uno, mappatura con sintesi ed estrazione di entita'.

| Grandezza | Valore misurato |
|---|---|
| Token per elemento | **circa 20.000** |
| Tempo per elemento | circa 68 secondi |
| Proiezione su 371 elementi | **circa 7,4 milioni di token, circa 7 ore** |

**La stima a priori era di 3-5 mila token per elemento: il valore reale e' da quattro a sei volte tanto.** Non era una stima sciatta, era una stima; e' esattamente per questo che la regola prescrive di misurare invece di assumere. Chi progetta un lotto sulla stima sbagliata dimensiona male tutto: la dimensione del lotto, il tempo, e la scelta se il lavoro entri o no in una finestra.

La conseguenza sul caso osservato e' netta e conferma la premessa del pacchetto: sette milioni di token non entrano in nessuna finestra di sessione, quindi **quel lavoro non e' affrontabile senza registro**, a prescindere da quanti agenti si lanciano in parallelo.

Il modo corretto di ricavare questo numero e' misurare il consumo della flotta **prima e dopo un lotto piccolo**, e dividere. Non serve altro, e va rifatto per ogni tipo di lavoro: venti mila token per elemento valgono per questa forma di mappatura su questa taglia di documenti, non in generale.

## Che cosa ha dimostrato il primo lotto reale

Dieci elementi su un corpus di trecentosettantuno, undici minuti, una flotta secondaria. Tre esiti, e due sono lezioni.

**Il presidio ha dato il numero vero mentre il registro dichiarava il falso.** L'agente ha scritto `"stato": "completato"`, che nello schema non esiste: il vocabolario ammette `fatto`. Un presidio che consultasse il campo di stato avrebbe riportato **zero elementi conclusi**, perche' quel valore gli e' sconosciuto, mentre sul disco c'erano dieci artefatti validi. Guardando il disco ha riportato **dieci conclusi** e ha segnalato a parte la deviazione di vocabolario.

> E' la dimostrazione pratica del principio: **la verifica sull'artefatto e' robusta anche a un agente che usa parole diverse dalle tue**, mentre la verifica sullo stato dichiarato sbaglia in entrambe le direzioni, e il falso negativo e' insidioso quanto il falso positivo perche' porta a rifare lavoro gia' fatto.

**Il vocabolario va dato per esteso nel mandato.** Scrivere "metti stato fatto" non basta: l'agente sceglie un sinonimo ragionevole e lo schema si sporca. Il mandato elenca i valori ammessi, letteralmente, e dichiara che sono un insieme chiuso.

**L'approvazione a richiesta e' incompatibile con il lavoro a lotti.** Con `approval_policy = "on-request"` l'agente si e' fermato a ogni comando che scrive, in attesa di una persona. Su dieci elementi e' un fastidio; su trecentosettantuno sarebbe una persona incatenata a un pulsante, che e' l'opposto del motivo per cui il lavoro era stato spostato su un'altra flotta. Per i lotti si avvia con l'approvazione disattivata, cosi' che i comandi dentro il perimetro passino e quelli fuori **falliscano** invece di chiedere. Chi approva concede anche persistenza a famiglie di comandi, quindi le esecuzioni successive sono meno interrotte, ma la prima resta presidiata.

## Rapporto con le regole del sistema

Attua `rules/token-economy.md` sul caso del corpus grande, e non la duplica: la disclosure progressiva resta la riduzione del costo per elemento, questo pacchetto aggiunge la riduzione del **numero** di elementi e la sopravvivenza alla fine della finestra.

Obbedisce alla sezione 17 nominando il proprio presidio e dichiarando cosa non copre; alla sezione 19 non fidandosi dello stato dichiarato; alla sezione 20 componendosi con `doc-ingest` e `ccusage` invece di rifarli.

## Vincoli e onesta'

Il presidio **non giudica la qualita'** di un esito, e non puo' farlo.

Il registro **non impedisce** a un agente di lavorare fuori da esso: e' un contratto, non una prigione. Se l'agente non lo aggiorna, il presidio se ne accorge alla passata successiva, non durante.

L'instradamento fra flotte **presuppone che esistano**, con identita' separate e configurate. Su una macchina con una sola flotta la regola e' inerte e il resto del pacchetto funziona comunque.

L'aritmetica in apertura e' un **ordine di grandezza con assunto dichiarato**, non una misura: serve a decidere se il lavoro entra o no in una finestra, e va rifatta con il consumo reale del proprio progetto.
