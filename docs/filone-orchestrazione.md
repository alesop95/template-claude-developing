# Filone: orchestrazione di più agenti

> Onda 3 di `docs/piano-potenziamento-2026-11.md`, dal mandato del proprietario del 2026-11-12: far lavorare più agenti insieme al costo minimo, a monte di ogni progetto, richiamabile per un progetto o per un compito. Contiene la lettura alla fonte degli strumenti indicati, la griglia con cui rileggere il template come harness, la tabella «quale strumento per quale lavoro» e la voce 1.6 sull'instradamento verso serbatoi gratuiti. Settore di destinazione: «Orchestrazione, sessioni e cataloghi di agenti». Indice dei filoni in `docs/FILONI.md`.

## Che cosa è stato letto, e come

Tredici fonti lette il 2026-11-16 da un subagent con il modello più economico, attraverso l'API di GitHub: metadati, la prima parte del README fino a ventimila byte e l'albero di primo livello. Nessuno script di installazione è stato letto, niente è stato installato. I numeri che i README dichiarano su agenti, strumenti e risparmi sono riportati qui solo quando servono al giudizio, e sempre come affermazioni della fonte. Le letture grezze stanno nel livello privato del template.

## Che cosa il template ha già, e la conclusione in breve

Il template orchestra già, con pezzi propri: `agenti-terminale` avvia più account dei due client e ne pulisce le sessioni, la posta fra sessioni fa parlare agenti di progetti diversi, `instradamento-modelli` manda il lavoro meccanico a modelli economici e tiene una riserva sul limite del piano, `lavoro-a-lotti` rende riprendibile un lavoro lungo, `agent-catalog` e `crea-agente` procurano gli specialisti, e i due client hanno di nativo i subagent, il lavoro in sottofondo e gli alberi di lavoro isolati.

La conclusione della lettura è che nessuno degli strumenti indicati va adottato come strato in più sopra questi pezzi. I meta-harness letti portano centinaia di strumenti, agenti e skill in una volta sola, cioè esattamente il carico di avvio che il mandato chiede di ridurre, e fanno ciò che i client fanno ormai da sé. Ciò che se ne prende è il disegno, caso per caso, ed è scritto sotto.

Una misura di questa stessa sessione vale più di ogni lettura, e va registrata qui. Il 2026-11-16 sette subagent avviati insieme per leggere queste fonti hanno esaurito in pochi minuti il limite delle cinque ore del piano per il modello intermedio, e quattro si sono fermati a metà. Il lavoro è stato rifatto con il modello più economico, che non era sotto limite, ed è arrivato in fondo. Tre conseguenze. Il parallelismo avvicina il limite, come dice `token-economy.md`, e sette lettori insieme sono troppi per un piano personale: tre alla volta è la misura che ha retto nei giri precedenti. La lettura di un README per estrarne campi fissi è lavoro da modello economico, non intermedio: la tabella dell'instradamento va corretta in questo senso. E la riserva era impostata sul solo limite settimanale: la soglia sulle cinque ore, lasciata a zero, è quella che sarebbe servita.

## Le fonti, con le quattro domande

`https://github.com/ruvnet/ruflo`, MIT, è un harness a sciami per Claude Code e Codex: memoria, hook, un server MCP con alcune centinaia di strumenti dichiarati. Il suo stesso README avverte che le estensioni girano con i permessi dell'account e senza isolamento, e nomina un servizio remoto proprio. Costa un server MCP molto largo sempre dichiarato in contesto. Chiusura: archiviata per il costo. Il template ha il tetto di sei server connessi e la regola che un lavoro a passo unico non passa da un server; uno strumento che ne porta centinaia in ogni sessione va contro entrambe.

`https://github.com/affaan-m/ECC`, MIT, è la raccolta più grande fra quelle lette: dichiara settantuno agenti, oltre trecento skill, hook, regole e uno scanner di sicurezza. Il proprietario la voleva esplorata e spulciata, e la lettura di oggi è solo la prima metà: il README, non le skill. Installata intera duplica ciò che il template ha e moltiplica il carico; il README stesso avverte che una doppia installazione raddoppia skill e hook. Chiusura: osservazione, con il modo d'uso deciso: si tratta come un catalogo esterno, alla maniera di `agent-catalog`, da cui si prende una skill alla volta dopo averla letta. Dello stesso autore merita una lettura a parte lo scanner `agentshield`, perché risponde a una richiesta del mandato, cioè controllare gli strumenti che il template adotta.

Headcount, di cbrock84, non è stato trovato: il repository non risponde e la ricerca non dà un candidato certo. Resta nominato e non letto. L'idea che il mandato ne prendeva, agenti organizzati come reparti installabili, è quella di `agent-catalog` e di `wshobson-agents`, già a catalogo.

`https://github.com/Contrastive-LM/CLM`, Apache-2.0, non è uno strumento per agenti: è un modello, con un server locale e gli script di addestramento, che il suo README presenta come una classe nuova. Nessun client lo usa come estensione. Il mandato chiedeva di capire se un modello che decide può stare accanto a uno che ragiona, e la risposta dalla lettura è che l'idea esiste già in forma usabile altrove: un classificatore piccolo e veloce che smista, come quello che `docs/filone-memoria-e-vault.md` descrive a proposito di Jev, e come fa l'instradamento del template quando sceglie il modello per tipo di compito. Chiusura: osservazione. La pagina web:https://contrastive-lm.notion.site non è stata letta.

`https://github.com/langflow-ai/langflow`, MIT, costruisce agenti e flussi in modo visuale e pubblica ogni flusso come strumento MCP. È un servizio web da tenere acceso. Chiusura: osservazione; ha senso dove qualcuno che non programma deve vedere e modificare un flusso, ed è materia del progetto che lo ospita. Per i flussi programmati il template ha già il profilo di stack di n8n.

`https://github.com/anomalyco/opencode`, MIT, è un altro agente da terminale, non un'estensione dei due che il template usa. Il mandato lo accostava a un modello locale per lavorare senza rete. Chiusura: osservazione, legata al pacchetto `llm-local`: il giorno in cui un progetto deve lavorare scollegato, è il client da provare con il modello locale, e il template non ha ancora un adattatore per un terzo client. `https://github.com/jesseduffield/lazygit`, MIT, è un'interfaccia da terminale per git, per la persona e non per l'agente: utile al proprietario per rileggere un diff prima di un commit, non cambia niente nel template. Chiusura: osservazione, senza voce di catalogo.

`https://github.com/citrolabs/ego-lite`, MIT sul repository con un browser scaricato a parte, condivide con l'agente lo stato del browser dell'utente: accessi, cookie, estensioni. Ogni permesso dato all'agente vale per tutti gli account aperti in quel browser. Chiusura: archiviata. Il template preferisce l'estensione nativa del client per il browser, che chiede il permesso sito per sito.

`https://github.com/aayushch/laya`, Apache-2.0, è un centro di notifiche che raccoglie posta, chat e calendario e li riassume con un modello, locale o remoto. Legge corrispondenza, quindi sta sotto la regola dei documenti personali, e non è uno strumento di orchestrazione. Chiusura: archiviata per il template; resta una scelta personale del proprietario, fuori dai progetti.

`https://github.com/NousResearch/hermes-agent`, MIT, è l'agente personale che il mandato voleva accanto al secondo cervello: impara skill dall'esperienza, tiene memoria, lavora in locale o su una macchina remota e risponde da un canale di messaggistica. È già citato nel catalogo. Due avvertenze dalla lettura: si installa con uno script scaricato ed eseguito, non letto, e la sua importazione può leggere le chiavi degli altri agenti se glielo si chiede. La lezione astratta per il template è quella già scritta nel piano: un agente sempre acceso ha senso se legge la stessa memoria versionata del progetto invece di tenerne una propria, ed è il vault di progetto a renderlo possibile. Chiusura: osservazione, da proseguire nel progetto del laboratorio, che ne ha già il documento di consegna.

OpenHuman risulta essere `https://github.com/tinyhumansai/openhuman`, GPL-3.0: un harness autonomo con applicazione desktop e server, modelli locali e decine di integrazioni con account di terzi. È un'alternativa ai due client, non un loro complemento. Chiusura: osservazione. MiroMind, cercato per nome, ha dato una famiglia di modelli per il ragionamento matematico, che non è lo strumento di ricerca a passi verificati che l'immagine del mandato descriveva: quello resta non identificato.

Il «DeepSeek Harness» del mandato non ha un repository indicato e non è stato letto. Il modello d'uso che il proprietario ne voleva, cioè attivazione su un evento, riproduzione del guasto, correzione e richiesta di unione, con più lavori in parallelo, esiste nei due client: Claude Code ha le attività programmate, il comando che osserva una richiesta di unione e ne corregge i difetti, e il comando che scompone un cambiamento in unità parallele su alberi isolati; il pacchetto `automation-starter` del template copre l'esecuzione senza interfaccia. Non serve un harness in più: serve provarlo su un progetto, e non è stato fatto.

## Instradamento verso serbatoi gratuiti (voce 1.6)

`https://github.com/cheaper-inference/OmniRoute`, MIT, espone un indirizzo locale unico e instrada ogni richiesta verso molti fornitori, con preferenza per quelli gratuiti e ripiego automatico quando una quota finisce; funziona con Claude Code e con Codex. La domanda del piano era quali dati escono, e la risposta è: tutti. Ogni prompt e ogni frammento di codice passa dal gateway e arriva al fornitore che in quel momento ha quota, cioè a terzi che non si sono scelti uno per uno e le cui condizioni sui dati non si sono lette. I risparmi dichiarati non hanno una misura ripetibile nella parte letta.

Chiusura: archiviata per i progetti dell'organizzazione e per ogni progetto con dati che non devono uscire; osservazione per un progetto personale senza dati sensibili, dove resta una scelta del proprietario. Il risparmio che il template propone al suo posto è quello che non sposta i dati: modello economico per il lavoro meccanico, modello locale dove basta, e meno elementi mandati a un modello.

## La griglia dell'harness

Lo schema che il proprietario ha indicato divide un harness in sei parti. Riletto con quella griglia, il template copre così.

| Parte | Che cosa la copre nel template | Che cosa manca |
|---|---|---|
| Contratto | `CLAUDE.md` e `AGENTS.md`, le regole sempre attive, la descrizione di ogni skill, il messaggio di milestone | Niente di strutturale |
| Contesto | Le schede di `.claude/context/`, la disclosure progressiva, la misura del carico di avvio, le regole condizionali per tipo di file | La misura del contesto consumato durante la sessione, che i client mostrano e il template non registra |
| Stato | La memoria versionata, il file di ripresa con l'impronta, il registro delle pendenze, il vault di progetto | Niente di strutturale |
| Strumenti | La cartella degli strumenti, il catalogo dei pacchetti con il gate, il tetto dei server connessi | Niente di strutturale |
| Permessi | La regola sui permessi, le impostazioni del progetto, la riserva dei subagent, gli hook | Per Codex la riserva vale solo all'avvio e solo dal wrapper |
| Prove | I controlli di chiusura, la norma sulle prove, le prove interne degli strumenti | Le prove delle skill: nessuna skill del template ha una suite che dica se, invocata, fa ciò che promette |

La casella vuota che conta è l'ultima. Gli strumenti in Python hanno prove; le skill, che sono testo, no. Claude Code ha un comando nativo per valutare un plugin o una skill con una suite di casi, e il 2026-11-16 le tre skill che decidono di più ne hanno ricevuto uno ciascuna, nella cartella `evals/` della skill: `riprendi` con una ripresa in cui la verifica segnala una divergenza, `cerca-pacchetto` con la richiesta di scrivere a mano una capacità che il catalogo ha, `gate-pacchetti` con un progetto appena inizializzato. Ogni caso è un prompt e un criterio che un modello giudice applica tre volte.

Esito della prima corsa, una esecuzione per caso e senza il braccio di confronto: `cerca-pacchetto` superato con tre voti su tre, `riprendi` superato con due su tre, al costo di circa un decimo di dollaro per caso. Il caso di `gate-pacchetti` non si può eseguire su Windows, ed è un limite della macchina e non della skill: la skill si invoca solo a mano e porta nel proprio testo un comando di shell che inietta il contesto, il comando di valutazione rifiuta di concedere una shell dove non può confinarla, e su questa piattaforma il confinamento non è attivo. Va eseguito su una macchina Linux. Una corsa sola non è una misura: il comando ne fa tre per caso e confronta con e senza la skill, e quella corsa completa non è stata fatta.

```
claude plugin eval .claude/skills/cerca-pacchetto --no-publish
```

L'opzione `--no-publish` tiene il rapporto in locale: senza, il comando lo pubblica sull'account.

## Quale strumento per quale lavoro

Il mandato chiedeva una tabella che separi i lavori, sul modello delle immagini consegnate, con ciò che è gratuito dichiarato e verificato. La colonna di destra dice che cosa è stato davvero verificato, ed è quasi sempre la sola lettura della fonte.

| Lavoro | Nel template | Alternativa letta | Verificato |
|---|---|---|---|
| Agente personale e secondo cervello | `vault-di-progetto` sopra la memoria versionata | Hermes, OpenHuman | Solo lettura; il vault non è ancora stato aperto in Obsidian |
| Ricerca a passi verificati | Il flusso nativo di ricerca del client, `academic-researcher`, `notebooklm-bridge` | Non identificata | Il flusso nativo è stato usato in sessioni precedenti; costa molto, come dice `token-economy.md` |
| Interfacce | `impeccable`, `taste-skill`, la skill di design dell'account | Un servizio di Google, non letto | Voci di catalogo non provate qui |
| Codice senza rete | `llm-local` | opencode con un modello locale | Il rilevamento del modello locale è provato; il client alternativo no |
| Flussi programmati e visibili | Il profilo di stack di n8n, `automation-starter` | Langflow | Solo lettura |
| Studio | `learning-agent`, `notebooklm-bridge` | open-notebook, da ospitare | Solo lettura |
| Agenti visuali | Nessuno | Langflow | Solo lettura |
| Sciami per lavoro meccanico | `instradamento-modelli` con la riserva, `lavoro-a-lotti` | I meta-harness letti | Misurato in questa sessione, con l'esito scritto sopra |

## Che cosa resta aperto

La ricerca strutturata su Reddit e dev.to, che il mandato chiedeva per tarare il costo su un piano personale, non è stata fatta: la misura di questa sessione ne è un primo dato, non un sostituto. Lo scanner dello stesso autore della raccolta più grande va letto. La suite di prove delle tre skill va eseguita per intero, e il caso del gate su Linux. La soglia della riserva sulle cinque ore è stata impostata all'ottanta per cento nelle sei radici di account e nei valori di macchina lo stesso pomeriggio. Headcount, lo strumento di ricerca a passi verificati e il «DeepSeek Harness» restano non letti.
