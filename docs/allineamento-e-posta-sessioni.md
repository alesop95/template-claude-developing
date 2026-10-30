# Allineamento visibile e posta comune fra Claude e Codex

Sviluppo del30/10/2026, su richiesta del proprietario e nota del progetto my-wedding-day. L-039 e L-040 sono attuate con controlli di stato, ricevuta e manutenzione dell’elenco che preserva i byte delle righe estranee. La distribuzione agli altri progetti richiede il commit manuale e la passata ufficiale.

## Esclusioni che restano visibili

La sintassi dell’elenco resta percorso seguito da # e motivo; il motivo accetta `| fino=AAAA-MM-GG`, `| condizione=descrizione` oppure `| permanente`. La passata continua a rispettare l’esclusione, anche scaduta, ma stampa scadenza, condizione da verificare o mancanza di scadenza e quanti commit separano l’ancora del progetto da HEAD del template. Non rimuove da sola un’esclusione. Se l’ancora è assente o non confrontabile lo dichiara, senza inventare zero. Prima di escludere per lavoro pendente confrontare prova a vuoto e git status: i file disgiunti non creano una collisione.

stato-template.py --rimuovi-esclusione ELENCO --progetto PERCORSO toglie una sola riga con corrispondenza esatta: copia preventiva verificata, divisione con splitlines(keepends=True), conservazione di BOM e terminatori di ciascuna riga, conteggio atteso e rilettura. Un duplicato non viene rimosso alla cieca. La copia privata permette recupero anche quando l’elenco non è versionato.

## Avviso all’apertura e ricevuta dopo la passata

verifica-ripresa.py consulta il helper stato-template.py disponibile accanto o sotto .claude/templates/tools. Il confronto usa l’ancora del marcatore e la storia git, elenca i pacchetti nuovi e distingue le modifiche a monte non committate, che non possono ancora essere propagate. PROJECT_TEMPLATE_ROOT, il puntatore privato o il repository fratello standard permettono di trovare la fonte. Un percorso non individuato resta non verificabile, non diventa verde.

La passata prepara .claude/ultimo-allineamento.md quando consegna cambiamenti e lo include nel rapporto dei file gestiti. Il commit dell’allineamento comprende quindi anche il riepilogo; la sessione lo legge con istruzioni uguali per i due agenti. La ricevuta elenca file e risultati, mantiene i conflitti come ancora aperti e non dice che una configurazione sia stata collaudata. Una ricevuta locale priva del marcatore del generatore viene rispettata come conflitto.

## Un terreno comune per le sessioni

Il pacchetto agenti-terminale aggiunge posta-sessioni.py e Posta-Sessioni.ps1. Entrambi i launcher registrano un partecipante univoco per sessione e aggiungono soltanto la cassetta privata comune al perimetro di scrittura tramite --add-dir. Il percorso è visibile all’avvio e modificabile con -Posta; -NoPosta disabilita il collegamento. Le variabili PROJECT_AGENT_MAILBOX_ROOT, PROJECT_AGENT_MAILBOX_ID e PROJECT_AGENT_MAILBOX_TOOL identificano la cassetta e il partecipante per gli strumenti disponibili all’agente. Non si apre la rete e non si usa il demone privato di Codex come bus.

La CLI registra, elenca, invia e legge; un file nasce completo tramite rinomina atomica, con limite128KiB, mittente e destinatario registrati. La lettura non consuma automaticamente il messaggio; --archivia lo sposta in letti. I nomi non permettono uscita dal percorso della casella. La cassetta non autentica due processi dello stesso utente e non sveglia una sessione inattiva: gli agenti controllano all’apertura e ai giri successivi. Le sessioni già avviate non ereditano retroattivamente nuove variabili o --add-dir. Un dialogo fra sessioni reali resta un collaudo distinto dalle prove del trasporto.

La funzione claude-account<N> passa ora da Avvia-Claude.ps1; codex-account<N> continua a passare da Avvia-Codex.ps1. Il Codex launcher comune usa il numero richiesto per la pulizia in finally, quindi1,2 e3 hanno lo stesso comportamento. Claude conserva il proprio hook di pulizia. La disponibilità della funzione è comune; i meccanismi interni restano quelli supportati dai runtime. Nessun commit, push o comando ricevuto in un messaggio viene eseguito automaticamente.

## Riscontri di consegna

Regressioni complete55 positive, verifica-ripresa28 prove positive e autotest allinea-tutti24 casi positivi. Le prove esercitano gli account Codex1/2/3 anche in errore e la stessa cassetta esposta da entrambi i launcher. Il framework pytest, già presente in ambiente, è una dipendenza di test: pagina primaria PyPI letta il30/10, licenza MIT; nessuna installazione o versione nuova applicata. La registrazione nella cassetta non è un heartbeat o una prova che un agente abbia letto: il dialogo fra sessioni reali rimane da riscontrare. La pulizia globale è stata provata soltanto a vuoto, nessuna sessione cancellata dal lotto.
