---
name: crea-agente
description: Crea un agente di programmazione per il progetto, cioè un subagent in `.claude/agents/`, dopo aver letto il progetto e aver chiesto solo ciò che non ha potuto capire da sé.
argument-hint: "[il lavoro che l'agente deve fare]"
disable-model-invocation: true
---

# Creare un agente di programmazione

Il lavoro da affidare è `$ARGUMENTS`. Se è vuoto, la prima domanda è quale lavoro si ripete abbastanza da meritare un agente.

## 1. Capire prima di chiedere

Leggi ciò che il progetto dice già: `CLAUDE.md`, `.claude/memory/index.md` se esiste, la scheda di contesto che copre la parte di codice interessata, i comandi di build e di prova, gli agenti già presenti in `.claude/agents/`. Poi scrivi in non più di cinque righe che cosa hai capito: che cosa fa l'agente, su quali file, con quale esito atteso. È il testo su cui il proprietario ti corregge, ed è più utile di qualunque domanda.

Prima di proseguire controlla che l'agente non esista già. Il catalogo ne ha quattro pronti nel pacchetto `subagent-template` e ne pesca altri a richiesta con `agent-catalog`; il client ne offre di nativi per la ricerca, il piano e la revisione. Se uno di questi basta, dillo e fermati.

## 2. Chiedere solo ciò che manca

Le domande nascono da ciò che hai capito, non da un questionario. Una alla volta, ciascuna con la risposta che proponi tu e il motivo, al massimo cinque. Non si chiede ciò che il repository dice già. I punti che di solito restano aperti sono questi, e si chiedono solo quelli davvero aperti.

- Il confine: che cosa l'agente non deve toccare, e se scrive file o legge soltanto.
- Il giudizio: se il lavoro si verifica leggendo il risultato è meccanico e va su un modello economico; se decide qualcosa su cui il passo dopo si appoggia resta sul modello della conversazione. È la distinzione di `.claude/rules/token-economy.md`.
- La prova: come si capisce che l'agente ha finito bene, cioè quale comando o quale controllo lo dice.
- L'isolamento: se lavora in parallelo ad altri sugli stessi file gli serve un albero di lavoro proprio.
- Il ritorno: che cosa deve riportare, in quale forma, e che cosa deve dichiarare di non aver verificato.

## 3. Scrivere la definizione

Il file è `.claude/agents/<nome>.md`, con il nome in minuscolo e trattini. Il front matter usa i soli campi che servono; quelli documentati dal client sono `name`, `description`, `tools`, `disallowedTools`, `model`, `effort`, `maxTurns`, `skills`, `isolation`, `permissionMode`, `memory`, `background`.

```markdown
---
name: <nome>
description: <quando delegare a questo agente, con le parole con cui il lavoro si presenta>
tools: Read, Grep, Glob
model: inherit
maxTurns: 30
---

Ruolo in una frase.

Che cosa ricevi, e che cosa fai se manca.

Procedura, nell'ordine in cui la esegui.

Che cosa non fai: non esegui git add, commit o push; non scrivi fuori dal perimetro indicato.

Che cosa riporti: l'esito, i file toccati, e che cosa non hai verificato.
```

La descrizione decide se l'agente verrà mai usato: dice quando delegare, non che cosa l'agente è. Gli strumenti sono i minimi: un agente che legge non riceve quelli di scrittura. `maxTurns` c'è sempre, perché un agente senza tetto consuma finché trova qualcosa da fare. I vincoli del progetto si ripetono nel corpo, perché un subagent parte da un contesto proprio: stile, versionamento manuale, documenti personali.

## 4. Collegarlo al resto

Se il lavoro è meccanico e la macchina usa il pacchetto `instradamento-modelli`, proponi la riga da aggiungere alla tabella dell'account, senza scriverla tu. Se il progetto usa anche Codex, dichiara che la definizione vale per Claude Code e che l'equivalente Codex, cioè una voce `agents.<nome>` della sua configurazione, va scritto a parte e non è stato provato da questa skill.

## 5. Provarlo una volta

Lancia l'agente su un caso piccolo e vero, leggi che cosa riporta e confrontalo con la prova concordata al punto 2. Se ha sbagliato, la correzione va nella definizione e non nel prompt di quella volta. Chiudi dicendo quale file hai scritto, com'è andata la prova e che cosa resta da decidere al proprietario. Non esegui git add, commit o push.
