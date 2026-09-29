# template-claude-developing

> Istruzioni di team di questo repository, che è il template stesso del sistema di progetto e non un progetto che lo adotta. Lo standard completo sta in `.claude/PROJECT-SYSTEM.md`, le regole sempre attive in `.claude/rules/`, le norme caricate su richiesta nelle skill che l'indice qui sotto elenca, il catalogo dei pacchetti opzionali in `.claude/templates/PACKAGES.md`, e il percorso per estendere il sistema nella sezione "Come estendere il sistema" del `README.md` di radice.

Una modifica committata sotto `.claude/` del template non arriva da sola ai progetti istanziati: la porta `.claude/templates/tools/allinea-tutti.ps1 -Applica`, che l'utente lancia dopo il commit, seguita da un commit per ogni progetto che la passata elenca come applicato. `chiudi` lo ricorda da sé dopo il push con `passata-in-sospeso.py`, e l'agente lo ripropone comunque a ogni milestone che tocca `.claude/`. I progetti che la passata lascia in `conflitti` si chiudono a mano e si registrano con `allinea-dal-template.py --risolto <percorso>`.

Quando cambia una capacità pubblica del template, usa la skill `.claude/skills/sync-readme/` per aggiornare la prosa del README e poi esegui `python .claude/templates/readme-sync/tools/sync-readme.py --write --bundle`. Prima di consegnare comandi di version control esegui la stessa CLI con `--check --bundle`: controlla indice, inventario e link locali.

A fine sessione aggiorna `_notes/RESUME-PROMPT.md` e scrivi in `_notes/COMMIT-MSG.txt` il messaggio di commit proposto. La chiusura la esegue l'utente, dopo aver chiuso Claude, con `.claude/templates/tools/chiudi-sessione.ps1`: controlli, commit con conferma, push verificato, impronta e wipe. Lo stesso vale per ogni milestone a metà sessione: a blocco concluso scrivi `_notes/COMMIT-MSG.txt` e proponi `chiudi`, una milestone per commit, invece di consegnare comandi git sparsi.

## Norme caricate su richiesta

Quattro norme del sistema non stanno in `.claude/rules/` e non entrano quindi in contesto a ogni sessione: vivono come `RIFERIMENTO.md` dentro la skill che le governa e si caricano quando la loro situazione si presenta. La ragione, con il budget che la impone, sta nella sezione 24 di `.claude/PROJECT-SYSTEM.md`. L'indice che segue è ciò che rende affidabile quel caricamento, perché nomina la situazione con le parole con cui si presenta invece del nome del file: riconosciuta una di queste situazioni, si invoca la skill prima di procedere.

- Si scrive o si valuta una prova automatica, si chiude un difetto, una verifica manuale smentisce una suite verde, si aggiunge una guardia o un'esclusione, si sta per dichiarare completo un intervento il cui scopo era un effetto misurabile: skill `prove-che-misurano`.
- Un recupero web fallisce con 403, con un rinvio alla pagina di accesso o con una pagina di verifica anti-bot, la fonte sta su Reddit o su Discord, serve la trascrizione di un video, si sta per annotare nel registro una fonte non letta: skill `fonti-non-recuperabili`.
- `git worktree list` mostra più di un albero, se ne crea o se ne rimuove uno, si apre una sessione in un albero che non è il principale, si deve decidere da dove leggere la memoria versionata: skill `alberi-di-lavoro`.
- Si inizializza o si allinea il progetto, oppure cambia il modo in cui si prova e si rilascia, e va deciso come separare test e produzione: skill `separazione-ambienti`.

## Convenzione Markdown

I file `.md` di questo repository si scrivono con i paragrafi su una riga sorgente continua: nessun a capo manuale a colonna fissa, nessuna riga spezzata a metà frase. L'a capo separa due paragrafi distinti, mai due frasi o due porzioni della stessa frase, perché l'avvolgimento a video resta compito dell'editor o del renderer e non del file sorgente. Il motivo è pratico: con i paragrafi su riga unica il diff git segna esattamente i paragrafi cambiati invece di ri-avvolgere righe che nessuno ha toccato, e la ricerca testuale per frase funziona.

Restano intatti le righe vuote tra i blocchi, i titoli in entrambi gli stili, le linee orizzontali, il front matter, i blocchi di codice recintati e quelli indentati, le tabelle riga per riga e senza riallineamento, i blocchi HTML, le definizioni di link di riferimento e l'indentazione che definisce l'annidamento delle liste. Una voce di elenco sta su una riga sola, marcatore incluso. Un `<br>` si ottiene solo con due spazi a fine riga, e solo quando l'interruzione è intenzionale. Di ogni file si conservano la fine riga (CRLF o LF), il newline finale e l'eventuale BOM.

Dopo aver creato o modificato un file `.md`, si esegue lo strumento di unwrap, che attua la convenzione senza normalizzare nient'altro.

```
python .claude/templates/md-unwrap/tools/md-unwrap.py <file o cartella>
python .claude/templates/md-unwrap/tools/md-unwrap.py --check --oracle require .
```

La seconda forma è la verifica non distruttiva da eseguire prima di preparare un commit: esce con codice diverso da zero se qualche file non rispetta la convenzione, e non scrive nulla. La convenzione in forma normativa, con il dettaglio dei casi, sta nella regola `.claude/rules/interaction-style.md`, sezione "Formattazione dei file Markdown"; il funzionamento dello strumento, la logica di disambiguazione e l'oracolo di correttezza stanno in `.claude/templates/md-unwrap/README.md`. Le fixture di test sotto `.claude/templates/md-unwrap/tests/fixtures/` sono materiale di confronto byte per byte e sono protette dal marcatore `.md-unwrap-ignore`: non si riscrivono mai.

## Vincoli di team

Le operazioni di `git add`, commit e push restano sempre manuali dell'utente: l'agente prepara i file, non committa. Il formato con cui si presentano i comandi git è quello della regola `.claude/rules/git-commands-format.md`, l'identità git quella di `.claude/rules/git-identity-and-repo.md`. Lo stile di documentazione e di interazione è quello di `.claude/rules/interaction-style.md`, e vale per ogni file scritto qui dentro, template inclusi.
