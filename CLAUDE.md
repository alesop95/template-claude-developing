# template-claude-developing

> Istruzioni di team di questo repository, che è il template stesso del sistema di progetto e non un progetto che lo adotta. Lo standard completo sta in `.claude/PROJECT-SYSTEM.md`, le regole normative caricate su necessità in `.claude/rules/`, il catalogo dei pacchetti opzionali in `.claude/templates/PACKAGES.md`, e il percorso per estendere il sistema nella sezione "Come estendere il sistema" del `README.md` di radice.

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
