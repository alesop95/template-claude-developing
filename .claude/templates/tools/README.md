# tools

## render-diagrams.mjs

Rende i diagrammi Mermaid di `.claude/context/diagrams/*.mmd` nei corrispondenti `.svg`, riusando il browser Chromium-based già installato sul sistema (Edge o Chrome). Non scarica il Chromium di Puppeteer: il download e disattivato e si punta al browser locale, così la generazione resta snella e ogni progetto e autonomo.

Uso:

```
node tools/render-diagrams.mjs
```

Per rendere una cartella diversa:

```
node tools/render-diagrams.mjs <cartella>
```

Prerequisiti: Node e un browser Edge o Chrome. Alla prima esecuzione `npx` scarica i soli script di mermaid-cli, mai un browser. Se l'autorilevamento del browser fallisce, forzalo con la variabile d'ambiente `PUPPETEER_EXECUTABLE_PATH` puntata all'eseguibile di Edge o Chrome.

I `.svg` prodotti sono versionati accanto ai `.mmd` sorgente, secondo l'anatomia canonica del sistema di progetto.

## lint-md-commands.py

Percorre i blocchi di codice di shell dentro i file Markdown e segnala i comandi che non si possono copiare in una riga sola: continuazioni di riga (backslash di bash, backtick di PowerShell, caret di cmd), heredoc multi-riga e comandi git che proseguono sulla riga seguente. Esiste perché `md-unwrap` per contratto lascia verbatim il contenuto dei blocchi recintati, quindi un comando spezzato dentro un blocco di codice non viene corretto da nessuno strumento e va trovato a parte. Attua la verifica richiesta dalla regola `.claude/rules/git-commands-format.md`.

```
python tools/lint-md-commands.py .
```

È in sola lettura e non scrive nulla: esce 0 se non trova niente, 1 altrimenti, quindi si può usare come gate in pre-commit o in CI accanto a `md-unwrap --check`. Un blocco viene considerato shell solo se lo dichiara la info string (`bash`, `powershell`, `sh`, `console` e simili) oppure se non ha info string e contiene comandi: un blocco `markdown` o `text` che cita un comando resta prosa, e la prosa può finire legittimamente con un backtick di code span. Le continuazioni backslash dentro un blocco dichiarato `bash` restano segnalate ma sono legittime se il comando è specifico di quella shell e non è destinato al copia-incolla cross-piattaforma: la segnalazione serve a decidere, non a imporre.

## detect-ssh-profiles.py

Rileva, in sola lettura, i profili SSH verso GitHub configurati sulla macchina dove gira, e serve al Passo 0.5 dell'inizializzazione e dell'allineamento. Esiste perché la regola `git-identity-and-repo.md` non può sapere quali alias e quali chiavi esistano dove viene letta: un alias e una convenzione della singola installazione, non un fatto del sistema di progetto, e assumerlo porta a configurare un remoto che punta a un profilo inesistente, con un errore che si manifesta solo al primo push. Lo strumento e unico e non ha una variante per sistema operativo, perché il formato di `ssh_config` non ne ha.

```
python .claude/templates/tools/detect-ssh-profiles.py --repo .
```

Risolve il file di configurazione dell'utente insieme alle sue direttive `Include`, elenca gli alias il cui `HostName` e `github.com` con la chiave che ciascuno seleziona, dichiara se quel file di chiave esiste davvero, segnala le chiavi presenti in `~/.ssh` che nessun alias richiama e i blocchi `Match` che non ha interpretato, e riporta l'identità git globale con `user.useConfigOnly` più identità locale, remoto e `core.sshCommand` del repository indicato da `--repo`. Con `--json` produce la stessa informazione in forma strutturata. Non stampa mai materiale di chiave, solo percorsi e nomi. Esce 0 se trova almeno un alias verso GitHub e 1 se non ne trova nessuno, caso in cui non c'è niente da scegliere e il profilo va creato prima di proseguire.

Il suo output e il materiale della domanda all'utente, non la risposta: il nome di un blocco `Host` e una mnemonica di chi ha configurato quella macchina e non dice a quale identità vada abbinato, quindi alias, `user.name`, `user.email` e owner di destinazione si chiedono e non si deducono.

## check-account-hygiene.ps1

Verifica, in sola lettura, che l'account Claude Code attivo rispetti l'igiene del magazzino nascosto richiesta dal sistema: `autoMemoryEnabled: false`, un hook `SessionEnd` che esegue `session-end-wipe`, e che lo script di wipe installato sia configurato per questa macchina e non per un'altra. Il terzo controllo invoca lo script installato nel suo modo di sola lettura e distingue due guasti che i primi due non vedono: il template copiato ma mai compilato, con i prefissi ancora al segnaposto, e il caso in cui nessuno degli slug presenti corrisponda ai prefissi configurati, che è la firma di una configurazione presa da un'altra macchina. Si esegue al Passo 0 dell'inizializzazione o dell'allineamento di un progetto, e non modifica nulla: stampa un report PASS/FAIL e, se l'account non è in regola, indica cosa aggiungere. Vedi PROJECT-SYSTEM.md sezione 15.

```
powershell -NoProfile -ExecutionPolicy Bypass -File .claude/templates/tools/check-account-hygiene.ps1
```

Determina l'account attivo da `CLAUDE_CONFIG_DIR`, con fallback su `%USERPROFILE%\.claude`, e ne legge il `settings.json`. Esce con codice 0 se l'account è in regola, 1 altrimenti. Su Linux la variante equivalente e `check-account-hygiene.sh` (`bash .claude/templates/tools/check-account-hygiene.sh`), che legge il JSON con `python3` e, in sua mancanza, ricade su un controllo testuale.

## session-end-wipe.ps1

Template del wipe del magazzino nascosto, da installare per-account, non per-progetto. Si copia in `<CLAUDE_CONFIG_DIR>\hooks\session-end-wipe.ps1` insieme a `scrub-claude-json.js`, si sostituiscono i segnaposto `<CLAUDE_CONFIG_DIR>`, `<KEEP_PREFIXES>` e `<KEEP_PATH_PREFIXES>`, e si registra come hook `SessionEnd` nel `settings.json` dell'account, o nel `settings.local.json` se quella home non ha un `settings.json`. A ogni chiusura di sessione ripulisce i transcript e la memoria nascosta dei progetti non preservati e gli store per-account effimeri, lasciando intatti i progetti il cui slug corrisponde a uno dei prefissi da preservare, la configurazione, il login, le skill, i plugin e lo stato del daemon. I prefissi dipendono dalla macchina, uno per ogni radice dove stanno i progetti di sviluppo, e il template non ne porta uno di default ma un segnaposto che blocca lo script: un default che funziona su una macchina è una trappola su tutte le altre, perché su Linux gli slug derivano dal percorso assoluto e un prefisso come `D--` non corrisponde a niente, l'insieme dei progetti preservati risulta vuoto e il wipe cancellerebbe l'intero magazzino senza segnalare nulla. Da qui le tre guardie che precedono ogni rimozione: la home dell'account deve esistere e assomigliare a un magazzino di Claude Code, i prefissi devono essere stati compilati, e almeno uno slug presente deve corrispondervi, altrimenti lo script si ferma dichiarando che la configurazione è di un'altra macchina. L'esito dell'ultima corsa, rifiuti compresi, finisce in `session-end-wipe.log` nella home dell'account, perché un hook `SessionEnd` gira senza che nessuno ne veda l'output. Su Linux la variante equivalente e `session-end-wipe.sh`, registrata con un hook il cui comando e `bash "<CLAUDE_CONFIG_DIR>/hooks/session-end-wipe.sh"`. I prefissi non si indovinano: entrambe le varianti hanno un modo di sola lettura, `-List` su Windows e `--list` su Linux, che elenca gli slug realmente presenti marcandoli come preservati o da rimuovere e funziona anche sul template non ancora compilato, e un modo `-DryRun` oppure `--dry-run` che stampa ogni rimozione senza farne nessuna. L'ordine corretto è elencare, chiedere all'utente quali radici preservare mostrandogli l'elenco, compilare, provare a vuoto e solo allora registrare l'hook. La procedura completa e le sue varianti sono in PROJECT-SYSTEM.md sezione 15.

Oltre agli store storici lo script copre tre residui che altrimenti sopravvivono al wipe. Il primo sono le cache e i registri di stato per-account, ovvero `cache/`, `jobs/`, `ide/`, `todos/`, `statsig/`, `telemetry/` e `mcp-needs-auth-cache.json`. Il secondo sono gli scratchpad temporanei che Claude Code tiene in `%LOCALAPPDATA%\Temp\claude\<slug-progetto>` su Windows e in `$TMPDIR/claude/<slug-progetto>` su POSIX, con una sottocartella per sessione e gli output dei task: quella radice e condivisa fra tutti gli account della stessa utenza, quindi il passaggio e idempotente e chi chiude per ultimo la ripulisce. Il terzo e l'elenco dei percorsi aperti dentro `projects` di `.claude.json`, che senza questo passaggio sopravvive a ogni pulizia; se ne occupa `scrub-claude-json.js`. Di quest'ultimo passaggio va tenuto presente un effetto collaterale voluto: rimuovendo la voce di un progetto si rimuove anche il suo `hasTrustDialogAccepted`, quindi Claude Code richiede di nuovo di fidarsi della cartella al successivo avvio su quel percorso.

## scrub-claude-json.js

Companion di `session-end-wipe`: rimuove da `.claude.json` le sole voci di `projects` i cui percorsi non iniziano con uno dei prefissi da preservare, lasciando intatto tutto il resto del file, login e credenziali compresi. Si installa accanto allo script di wipe, in `<CLAUDE_CONFIG_DIR>\hooks\scrub-claude-json.js`, e non si invoca a mano: lo chiama il blocco 4 del wipe, una volta sul file di configurazione e una sull'eventuale `.claude.json.backup`, che altrimenti conserverebbe le stesse voci.

```
node scrub-claude-json.js <percorso .claude.json> <prefisso> [<prefisso> ...]
```

I prefissi sono percorsi e non slug, passati come argomenti distinti perché i percorsi con spazi non richiedano accorgimenti: su Windows di norma la radice del disco dei progetti (`D:`, `E:`), su POSIX la radice della cartella di sviluppo (`/home/utente/dev`). Il confronto e case-insensitive, che è cio che serve su Windows dove lo stesso progetto compare a volte come `e:/x` e a volte come `E:/x`, ed è comunque il verso prudente per uno script distruttivo. Attenzione a una trappola nel provarlo da Git Bash su Windows: la shell converte gli argomenti che sembrano percorsi POSIX in percorsi Windows prima di passarli a `node.exe`, quindi per un test con prefissi in forma `/home/...` serve `MSYS2_ARG_CONV_EXCL='*'`.

Il passaggio e in Node e non in PowerShell per una ragione precisa: `ConvertFrom-Json` di PowerShell 5.1 tratta le chiavi JSON come case-insensitive e va in errore su un `.claude.json` che contenga sia `e:/progetto` sia `E:/progetto`, condizione tutt'altro che rara. `JSON.parse`/`JSON.stringify` e invece la stessa semantica che Claude Code applica al proprio file. Poiché il file custodisce il login, non viene mai riscritto alla cieca: lo script verifica che l'oggetto in memoria contenga ancora `oauthAccount` e `userID`, valida il JSON prodotto, scrive su un file temporaneo, lo rilegge da disco e solo allora sostituisce l'originale; qualsiasi anomalia annulla tutto, lasciando il file intatto e senza residui. Se Node non è disponibile il wipe salta il passaggio senza toccare nulla.

## latest-screenshot.ps1

Restituisce il percorso dell'immagine più recente nella cartella di cattura di Screenpresso e la sua eta in secondi, perché l'agente legga lo screenshot appena catturato dall'utente per un passo manuale e visivo dello sviluppo. Si usa insieme alla regola `.claude/rules/manual-screenshots.md`, che stabilisce quando l'agente deve chiedere uno screenshot.

```
powershell -NoProfile -ExecutionPolicy Bypass -File tools/latest-screenshot.ps1
```

Cartella di default `%USERPROFILE%\Pictures\Screenpresso`, sovrascrivibile con `-Folder`. Con `-MaxAgeSeconds N` pretende che l'immagine più recente sia stata salvata da meno di N secondi, per non leggere per errore uno screenshot vecchio. Esce 0 se trova un'immagine valida, 1 altrimenti.

## claude-incognito.ps1 / claude-incognito.sh

Avvia una sessione Claude Code effimera: redirige `HOME` e le cartelle XDG su una directory temporanea e azzera `CLAUDE_CONFIG_DIR`, così la sessione non legge ne scrive nell'account reale e parte vergine; la temp si rimuove alla chiusura. Complementa `session-end-wipe` (quello pulisce dopo, questo non scrive nemmeno) ed è utile per lavorare su materiale sensibile.

```
powershell -NoProfile -ExecutionPolicy Bypass -File tools/claude-incognito.ps1 -ProjectDir "<percorso>"
```

Su Linux la variante e `claude-incognito.sh` (`bash claude-incognito.sh <percorso>`). La tecnica si basa sulla specifica XDG Base Directory più la redirezione di `HOME`; vedi PROJECT-SYSTEM.md sezione 15.
