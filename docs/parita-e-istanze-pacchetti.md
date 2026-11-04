# Procedure comuni e istanze dei pacchetti

Stato del lavoro del 2026-11-03, ramo `main`, base `832bdc0` con i contributi paralleli `18a4bca` e `2b747fc` conservati. Questa scheda descrive il contratto implementato; la pubblicazione del template e la distribuzione ai progetti dipendono dai passaggi manuali del proprietario.

## Che cosa significa parità

I due agenti leggono `CLAUDE.md`, le regole istanziate applicabili e le skill canoniche sotto `.claude/skills/`. `AGENTS.md` collega Codex a quella fonte e prescrive la ripresa anche senza un hook o un nome slash. In Codex CLI si può richiamare `$riprendi` o usare `/skills`; un client che non espone il selettore può comunque leggere il file canonico su richiesta. Il generatore mantiene i wrapper senza duplicare la procedura e conserva la policy di invocazione esplicita.

L'idempotenza riguarda una trasformazione con gli stessi ingressi: la seconda sincronizzazione dei wrapper e la seconda istanziazione autorizzata lasciano invariati byte e date dei file. Le risposte dei modelli e gli eventi dei due runtime non sono resi identici. Le prove su fixture verificano il contratto degli strumenti; il comportamento di una nuova sessione reale va osservato a parte.

## Un modello distribuito non è un pacchetto attivo

L'allineamento precedente copiava il magazzino dei modelli e aggiornava gli strumenti opzionali soltanto quando erano già presenti. Se il gate aveva saltato l'istanziazione, le passate successive potevano dichiarare aggiornati i file del template senza creare lo strumento, la regola o la configurazione del pacchetto. La presenza di una cartella sotto `.claude/templates/` prova soltanto la disponibilità della ricetta.

Il gate registra le scelte in `.claude/pacchetti.json`. Un contratto minimo ha questa forma:

```json
{
  "versione": 1,
  "pacchetti": {
    "anonymization": {
      "stato": "adottato",
      "data": "2026-11-02",
      "motivo": "Proteggere i dati documentati dal progetto"
    }
  }
}
```

Una ricetta pubblicata può fornire l'elenco dei file. Per gli altri pacchetti la voce adottata registra anche `file`, con coppie `origine` e `destinazione`: l'origine è interna al proprio pacchetto del template e la destinazione è relativa al progetto. Non sono ammesse destinazioni esterne, collegate fuori dalla radice, private o nel magazzino dei modelli. La convenzione `scripts/` esistente viene conservata per gli strumenti. Il contratto non contiene valori privati e non sostituisce una scelta mai raccolta: `rifiutato`, `rimandato` e assenza di decisione rimangono distinti.

`allinea-dal-template.py` inserisce nel piano i file adottati mancanti e li tratta con la storia, il confronto e i conflitti già previsti. Le origini devono essere nella testa pubblicata del template, così una modifica locale non committata non viene distribuita per errore. Il rapporto `PACCHETTI` e gli avvisi di `allinea-tutti.ps1` separano lo stato dei modelli da quello delle istanze e dalle decisioni da censire.

## Le condizioni dell'anonimizzazione

La ricetta comprende lo strumento, la regola e la norma dei casi osservati. Per essere giudicabile il controllo richiede anche un file di pattern privato, ignorato da Git, con lo schema previsto. Il verificatore legge solo la struttura e riporta lo stato senza esportare i valori. La presenza dello schema e di un richiamo nella chiusura non dimostra che l'intero controllo sia stato eseguito: richiamo e collaudo hanno stati separati. Il file privato non viene creato con valori inventati.

La ricetta resta opzionale finché una decisione del proprietario non cambia la dotazione comune. I progetti storici senza registro rimangono da censire, anche quando alcuni componenti esistono. La migrazione deve usare decisioni precedenti verificabili o una conferma concreta, senza trasformare il solo possesso di un modello in un consenso all'attivazione.

## Ripresa e chiusura

Le ancore `last-verified-commit` e `last-verified` devono essere antenate di `HEAD`. I due controlli rifiutano un oggetto fuori storia anche quando il suo albero è identico a quello corrente e un diff sarebbe vuoto. Data e soggetto possono suggerire un candidato dopo una riscrittura; non autorizzano una rimappatura senza revisione del contenuto. Le citazioni storiche restano oggetto di una lettura frase per frase.

Prima di committare, la chiusura confronta il perimetro preparato con i file reali e conserva uno snapshot dei contenuti scelti. Lo stage preesistente, un percorso atteso assente o un cambiamento dei file scelti dopo l'anteprima fanno fermare senza modificare quello stage. Se il perimetro è esplicito, gli altri file vengono mostrati e lasciati fuori: vengono aggiunti soltanto i percorsi scelti. Una conferma su più aree richiede che il messaggio le descriva tutte; non sostituisce l'isolamento quando sessioni diverse modificano gli stessi file. Durante questo intervento nessun allineamento è stato applicato ai progetti delle sessioni attive.

Una risoluzione manuale porta ora la firma del contenuto locale, normalizzata soltanto per la fine riga. Se il contenuto cambia, il vecchio registro non basta più a dichiararlo adattato. Lo stato `RISOLTO` include il file fuso e il registro nello stesso rapporto e nella ricevuta; prima del commit il controllo confronta la firma con il contenuto nell'indice. Il registro nuovo senza il file fuso corrispondente ferma sia la chiusura ordinaria sia quella dell'allineamento. Lo stage resta disponibile alla revisione.

## I contributi paralleli conservati

Il controllo dei riferimenti documentali distingue ora anche gli strumenti che il template porta ma che il progetto non ha mai istanziato, con 31 prove nell'autotest. È una verifica complementare al contratto dei pacchetti: il primo trova un comando nominato ma assente, il secondo verifica l'insieme dei file e la decisione di adozione. Nessuno dei due, da solo, prova l'esecuzione del controllo.

`gh-progetto.py` verifica il profilo Git e SSH dichiarato e seleziona le credenziali per il solo processo. Le associazioni reali di account restano private e non vengono distribuite; un profilo sconosciuto o ambiguo si ferma. Le prove sintetiche del contributo coprono 18 casi e una mutazione in memoria, senza alterare l'autenticazione reale. La regola nella skill `identita-git` è comune ai due agenti.

Il censimento delle fonti distingue i comandi citati dalle installazioni: non deduce più un'installazione dalla sola presenza di istruzioni in una skill. I binari npm vengono associati al pacchetto che li dichiara nei metadati delle dipendenze del progetto. Le annotazioni tecniche sull'EOL di Git e i nomi di fuso nel proprio contesto non diventano repository inventati.

## Verifica e limiti della consegna

Le regressioni usano repository temporanei e origini pubblicate nella fixture. Coprono oggetti Git esistenti fuori storia con alberi identici, il nome storico dell'ancora, una radice esplicita, sincronizzazioni ripetute senza riscritture, consegna dei soli modelli, adozione esplicita, ripristino dei file mancanti e destinazioni non ammesse. La chiusura è esercitata anche attraverso PowerShell su fixture con stage preesistente e file di un'altra sessione; la variante Bash conserva le prove su WSL. Risultati e mutazioni sono registrati nel checkpoint della consegna, con i limiti di ambiente separati dai risultati funzionali.
