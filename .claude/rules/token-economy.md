# Token economy

> Regola modulare. Consolida le pratiche di risparmio di contesto del sistema e indica quando
> valutare uno strumento esterno di ottimizzazione dei token. Si applica sempre, a ogni sessione.

## Principi nativi

Il sistema e' gia progettato per non sprecare contesto, e queste pratiche valgono sempre.

Densita sopra completezza: una sintesi densa vale piu di un estratto lungo. Si scrive e si legge
per segnale, non per volume.

On-demand: le skill, i capitoli di una skill-libro, le schede di `context/` e le pagine della wiki
si caricano solo quando servono al task, mai tutte insieme. Il `CLAUDE.md` indicizza i satelliti,
non li incorpora.

Niente riletture integrali: il motore di riconciliazione confronta i commit e legge solo le schede
pertinenti; i documenti voluminosi come i `.docx` si estraggono a fette, mai letti per intero, e si
tiene un mirror `.md` per i diff invece di rileggere il binario.

Si legge un file quando serve davvero, e solo la porzione necessaria, non l'intero file se non
occorre.

## Strumenti esterni, a scelta

Quando il risparmio nativo non basta, per esempio in sessioni operative molto lunghe e ricche di
output, si possono valutare strumenti esterni open source, sempre offerti come scelta al gate dei
pacchetti e mai imposti.

`caveman` riduce i token di output facendo rispondere l'agente in modo telegrafico, senza toccare
il ragionamento. E' utile nelle sessioni operative pesanti, ma va tenuto spento quando il progetto
produce documentazione o prosa leggibile, perche ne degraderebbe lo stile. Vive come tool di
sessione, non come stato del progetto. Vedi la voce `caveman` in `templates/PACKAGES.md`.

Per esigenze piu spinte esistono alternative come un server MCP di compressione e caching del
contesto (per esempio `token-optimizer-mcp`). Si adottano solo se il guadagno giustifica la
dipendenza, valutando caso per caso.

## Cosa non si fa

Non si introduce uno strumento di memoria globale che accumula stato fuori dal progetto: la memoria
del sistema vive dentro il progetto, versionata, e l'auto-memory nativa di Claude resta disattivata
(vedi sezione 15 di `PROJECT-SYSTEM.md`).
