---
name: research-scoping
description: >
  Definisce lo scope di un nuovo filone di ricerca prima di cercare o leggere alcun paper: domanda
  di ricerca, dominio disciplinare, tipo di revisione (sistematica o narrativa), orizzonte
  temporale, lingue accettate, e le scelte architetturali che dipendono dal contesto specifico
  dell'utente (libreria Zotero esistente o da zero, output LaTeX o Word, livello di autonomia,
  abbonamenti istituzionali disponibili). Usare all'inizio di un nuovo topic di ricerca, prima di
  invocare literature-search, e ogni volta che il progetto viene integrato in un contesto piu'
  ampio con altri pacchetti gia' presenti.
disable-model-invocation: true
---

## Premessa

Questa skill copre lo stadio 1 della pipeline a stadi (sezione 9, punto 1) e le domande di gate della sezione 18 di `research-vault/reference/claude-ricercatore-universitario-completo.md`. Non produce ricerca: produce lo scope entro cui la ricerca successiva (skill `literature-search`) e le altre skill del pacchetto operano.

## Domande da porre all'utente

Se non gia' chiarite in conversazione, la skill pone esplicitamente le seguenti domande prima di procedere, senza assumere risposte di default.

Qual e' il dominio disciplinare della ricerca, per calibrare quali database privilegiare (PubMed per biomedicina, DBLP per informatica, e cosi' via). Esiste gia' una libreria Zotero o JabRef da collegare, o si parte ex novo. Il progetto deve produrre output in LaTeX/Overleaf o in Word, perche' questo cambia quale MCP Zotero conviene attivare (vedi `../PACKAGES.md`, riga `zotero-mcp`). Quale livello di autonomia desidera l'utente: Claude propone sempre e aspetta conferma, oppure puo' procedere automaticamente su ricerca e verifica e chiedere conferma solo prima di scrivere il testo finale. Le nove modalita' di `corpus-analysis` vanno esposte come comandi espliciti o richiamate implicitamente quando Claude riconosce l'intento. A quali abbonamenti istituzionali a pagamento ha accesso l'utente, perche' determina quali fonti a pagamento configurare per prime. Se questo pacchetto va integrato in un progetto piu' ampio gia' esistente, quali altri pacchetti o moduli sono gia' presenti, per evitare sovrapposizioni con gestori di citazioni o skill di scrittura gia' definiti altrove.

## Il prompt di scoping

Oltre alle domande di gate, la skill definisce con l'utente la domanda di ricerca vera e propria, seguendo lo schema dello stadio 1: la domanda di ricerca in una frase, il tipo di revisione attesa (systematic review, narrative review, o esplorazione libera), l'orizzonte temporale delle fonti accettate, e le lingue accettate per i paper.

## Output

Le risposte si registrano in `research-vault/scope.md` (creato alla prima invocazione se assente), con una sezione per la domanda di ricerca e una tabella con le risposte alle domande di gate. Se il progetto usa gia' `.claude/context/current-work.md` per la feature attiva, lo scope vi si aggiunge come sezione dedicata invece di duplicare il file. Questo documento e' quello che `literature-search` e le altre skill leggono per sapere come operare in questo progetto specifico, invece di richiedere le stesse domande ogni volta.
