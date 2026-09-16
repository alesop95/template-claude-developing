# Formato dei comandi git per esecuzione manuale

> Regola modulare. Definisce come l'agente deve presentare i comandi git (add, commit, push) che l'utente esegue manualmente: in quale forma, cioè un comando per riga senza caratteri di continuazione, e in quale sintassi, cioè quella della macchina su cui si sta lavorando e non entrambe insieme. Vale ogni volta che l'agente fornisce comandi git da eseguire a mano.

## Principio

I comandi git restano sempre manuali dell'utente. Quando l'agente li presenta, li scrive in un formato immediatamente copiabile senza modifiche nel terminale che l'utente ha davanti: una riga per comando, nessun carattere di continuazione, nessun heredoc multi-riga, e la sintassi della shell su cui quella persona sta davvero lavorando invece di un doppio elenco che le chiede di scegliere.

Un comando non si spezza mai su più righe, per nessun motivo e a nessuna lunghezza. Non si usano caratteri di continuazione, né il backslash di bash, né il backtick di PowerShell, né il caret di cmd: sono specifici di una shell e rompono il copia-incolla sull'altra. Non si va a capo a mano per rientrare in una larghezza di colonna: l'avvolgimento a video è compito del terminale, esattamente come per la prosa di un file Markdown, e una riga lunga incollata resta un comando solo mentre una riga spezzata a mano diventa due comandi rotti. Se l'elenco dei percorsi rende la riga scomoda, la soluzione non è spezzarla ma accorciarla: si passa una cartella invece dei file che contiene, oppure si usa `git add -A` quando le modifiche da includere sono tutte quelle presenti, dichiarando nel testo che cosa entra nel commit. Questo vincolo vale sia per i comandi scritti in un file `.md` sia per quelli scritti direttamente in sessione nel terminale, e vale per ogni comando di shell che l'agente consegna all'utente perché lo esegua a mano, non solo per quelli di git.

Il vincolo va verificato, non solo dichiarato, perché lo strumento `md-unwrap` per contratto non tocca il contenuto dei blocchi recintati: un comando spezzato dentro un blocco di codice non lo corregge nessuno. Il controllo è `tools/lint-md-commands.py`, che percorre i blocchi di shell dei file Markdown e segnala continuazioni di riga, heredoc e comandi git che proseguono sulla riga seguente.

## Formato richiesto

I comandi si consegnano nella sola sintassi della macchina su cui si sta lavorando, non in entrambe. La shell dell'utente non è un'incognita: Claude Code dichiara all'avvio della sessione la piattaforma e la shell primaria, e quello è il dato da usare; dove mancasse lo si rileva in sola lettura, per esempio con `uname -s`, che su una macchina POSIX risponde con il nome del kernel e su Windows nudo non esiste. Su Windows si consegna quindi il solo blocco `powershell`, su Linux e macOS il solo blocco `bash`.

La ragione non è la brevità ma la precisione. Nella pratica di `git add`, `git commit -m` e `git push` i due blocchi sono identici carattere per carattere, e presentarli entrambi non aggiunge informazione: aggiunge una scelta davanti a due testi uguali. Dove invece la sintassi diverge davvero, come nella verifica della configurazione locale che su Windows passa da `Select-String` e su Linux da `grep`, oppure in un percorso o in una variabile d'ambiente, il blocco che non si userà resta comunque copiabile, ed è esattamente quello che prima o poi finisce incollato per sbaglio. Un solo blocco, quello giusto, toglie il problema alla radice.

Su una macchina Windows la consegna è quindi questa, e nient'altro.

```powershell
git add "percorso/file-uno" "percorso/file-due" "percorso/file-tre"
git commit -m "Messaggio sintetico del commit"
git push
```

La stessa sequenza, su Linux o macOS, si consegna così e soltanto così.

```bash
git add "percorso/file-uno" "percorso/file-due" "percorso/file-tre"
git commit -m "Messaggio sintetico del commit"
git push
```

Se i file da aggiungere sono molti, si usa `git add` con tutti i percorsi sulla stessa riga, separati da spazio, ciascuno tra doppi apici.

Quando il repository su cui si opera non è quello aperto nella sessione, il blocco si apre sempre con il proprio `cd`, su una riga a sé, con il percorso tra doppi apici e con le barre in avanti, che entrambe le shell accettano. Non si scrive in prosa di spostarsi in un'altra cartella lasciando i comandi senza: chi copia un blocco lo incolla dove si trova, e un `git add -A` eseguito nella cartella sbagliata è un errore che si scopre dopo il commit. La prescrizione nasce da una richiesta d'uso del 2026-09-15 in un progetto istanziato, dopo due sessioni in cui i comandi per un repository gemello erano stati dati senza.

La scelta si dichiara invece di restare implicita: una riga che dice per quale shell è il blocco basta a rendere verificabile il rilevamento, e a far correggere subito l'agente quando la macchina non è quella che ha creduto.

## Le due eccezioni

La prima eccezione è il testo destinato a essere letto altrove. Un comando scritto dentro un file del repository, cioè un README, una regola o la documentazione di un pacchetto, non ha davanti a sé la macchina di questa sessione ma un lettore ignoto, e là le due forme restano entrambe, affiancate ed etichettate, esattamente come nei due blocchi qui sopra. La distinzione è fra il consegnare e il documentare: si consegna a chi si conosce, si documenta per chi non si conosce.

La seconda eccezione è la richiesta esplicita. Se l'utente chiede entrambe le forme, per esempio perché deve passare i comandi a qualcun altro o perché lavora sulla stessa repository da due macchine, si danno entrambe senza discutere.

## Messaggio di commit

Il messaggio di commit è una sola stringa tra doppi apici, al massimo 72 caratteri, che descrive le modifiche in italiano nella forma "Aggiunte X, Y" oppure "Nuova regola X: descrizione" oppure "Aggiornato Y: cosa cambia". Se il contesto richiede più dettaglio, lo si scrive nella risposta testuale prima dei comandi, non nel messaggio di commit.

La clausola `Co-Authored-By` si omette quando si usa `-m` su riga singola: il commit header è sufficiente.

## Identità da verificare

Prima di fornire i comandi, l'agente verifica che la configurazione locale del repository sia corretta (user.name, user.email, remote origin) secondo la regola `git-identity-and-repo.md`. Se l'identità locale non è impostata, propone i comandi di configurazione prima di quelli di commit.
