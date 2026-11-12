# Filone: setup e diagnosi del client

> Aperto il 2026-11-12 dal mandato del proprietario, che chiede di poter controllare la configurazione di Claude Code su Windows e su Linux e di ritrovarla nella mappa e nella guida d'uso. Settore di destinazione: «Fondamenta e igiene del progetto». Stato: procedura scritta dai fatti della documentazione, nessuno strumento nuovo, niente provato su una configurazione rotta di proposito.

## La fonte e che cosa ne è stato letto

La fonte è la pagina ufficiale web:https://code.claude.com/docs/en/debug-your-config , già nel registro delle fonti a monte. Il 2026-11-12 l'ha letta un subagent dedicato alla documentazione di Claude Code, che ne ha riportato il contenuto con citazioni; chi scrive non ha riletto la pagina. Tutto ciò che segue sui comandi del client viene da lì.

## La domanda a cui risponde

Una regola, un'impostazione, un hook, un server MCP o una skill del progetto non sta facendo effetto, e non si sa se non è stata caricata, se un'altra impostazione la scavalca o se è scritta nel posto sbagliato. Il sistema di progetto ha propri controlli per la metà che riguarda i file, e il client ha i propri per la metà che riguarda ciò che ha davvero caricato: la diagnosi li usa insieme, in quest'ordine.

## La procedura, dal più economico

Il primo passo è guardare che cosa occupa il contesto. Nel client `/context` lo divide per categoria, cioè prompt di sistema, strumenti, strumenti MCP, subagent con la loro provenienza, file di memoria, skill e messaggi, e `/context all` espande l'elenco. Dal lato del progetto la stessa domanda sui soli file di istruzioni la misura `tools/misura-istruzioni.py`, che conosce la soglia di guardia del sistema e il tetto per singola regola e non conta le regole con front matter `paths:`, perché quelle si caricano solo quando l'agente tocca un file che corrisponde. I due numeri non coincidono per costruzione: lo strumento conta caratteri di file, il client conta ciò che ha in contesto.

Il secondo passo è la categoria che non torna. `/memory` elenca i file di istruzioni caricati; un `CLAUDE.md` di sottocartella non compare finché non serve, quindi la sua assenza lì non è un guasto. `/skills` elenca le skill, e una skill con `disable-model-invocation: true` è attesa fuori dal contesto. `/hooks` mostra gli hook registrati: il matcher è una stringa, sensibile alle maiuscole, con più valori separati da barra verticale. `/mcp` mostra i server e chiede l'approvazione di quelli dichiarati nel progetto. `/permissions` mostra le regole di permesso e `/status` l'account e il modello, che è anche il controllo che la skill `identita-git` chiede quando l'account non è quello atteso.

Il terzo passo è la precedenza. Le impostazioni si risolvono nell'ordine gestite, locali, di progetto, utente, con variabili d'ambiente e opzioni di riga di comando sopra: un valore giusto nel file di progetto può essere scavalcato da uno locale. `/doctor` nel client e `claude doctor` da terminale fanno una diagnosi in sola lettura.

Il quarto passo, quando i primi tre non spiegano, è il registro. `claude --debug`, o `claude --debug=mcp` per i soli server, scrive un registro per sessione sotto la cartella di configurazione dell'account, nella sottocartella `debug`.

L'ultimo passo è togliere tutto e rimettere un pezzo alla volta: `claude --safe-mode`, oppure una cartella vuota come `CLAUDE_CONFIG_DIR` con le sole impostazioni utente. Se il problema sparisce a configurazione pulita, è nella configurazione e non nel progetto.

## Che cosa cambia fra Windows e Linux

La procedura è la stessa. Cambiano tre cose che il sistema già tratta altrove: la cartella di configurazione, che su una macchina con più account è una per account e va nominata per esteso; gli hook, che il pacchetto `hooks-starter` consegna in due varianti, PowerShell e shell, e che vanno registrati con quella della macchina; e il sandbox, che su Windows nativo non c'è, come dice `.claude/rules/security-permissions.md`. `tools/verifica-portabilita.py` segnala i percorsi e i comandi di una sola piattaforma rimasti nei file del progetto.

## Che cosa manca perché diventi una voce di catalogo

Manca la prova: la procedura non è stata eseguita su un guasto vero o provocato, quindi non si sa se l'ordine dei passi è quello che fa trovare prima la causa. Manca il lato Codex, di cui non è stata letta la documentazione equivalente. E manca la decisione sulla forma: una skill a invocazione manuale che guidi i cinque passi sembra la forma giusta, perché non costa contesto, ma si scrive dopo la prova.
