# documentazione-didattica

Convenzione e due strumenti per tenere, accanto al registro di che cosa è accaduto, un registro di **perché una scelta è migliore di un'altra**. Estratto da un progetto istanziato da questo template, dove lo schema ha raggiunto sessantuno schede prima di essere generalizzato, e dove ciascuno dei presidi descritti qui sotto viene da un difetto osservato sul campo e non da una riflessione a tavolino.

## Il problema che risolve

Un work-log registra i fatti: che cosa è stato fatto, quando, su quali file. È indispensabile e non basta, perché il fatto sopravvive al ragionamento che lo ha prodotto. Fra sei mesi resta scritto che una funzione è stata estratta, e non resta scritto perché estrarla fosse meglio che correggerla dov'era, quale alternativa è stata scartata, e quale errore aveva reso evidente la necessità. **Il perché di una scelta è la prima cosa che si perde**, e si perde in silenzio, perché nessuno si accorge dell'assenza di una spiegazione che non è mai stata scritta.

La convenzione separa i due registri e dà a ciascuno un proprietario. Il work-log tiene i fatti in ordine cronologico inverso. Un **racconto evolutivo** tiene il filo del perché, contrapponendo per ogni passo com'era e perché fragile a com'è e perché meglio. E ogni voce del racconto rimanda a una **scheda numerata** che entra nel codice.

## La forma

Le schede stanno in una cartella unica e si chiamano con un prefisso, un numero progressivo e uno slug parlante, per esempio `refactor-49-un-default-che-porta-un-percorso-di-fallimento.md`. Il numero non si riusa mai, nemmeno quando una scheda viene superata: una scheda superata si marca come tale e resta, perché il rimando che qualcuno ha scritto altrove deve continuare a puntare a qualcosa.

Ogni scheda dichiara nel front matter i percorsi del codice di cui parla. Questo campo è l'unico aggancio meccanico fra una spiegazione e il codice che spiega, e la sezione sui modi di fallire dice perché senza di esso l'intero impianto si degrada da solo.

```yaml
---
covers-paths: ["src/App.tsx", "src/hooks/useAuthClaims.ts"]
last-verified-commit: 86d0154
---

# Refactor 49 - Un default puo' portare con se' un intero percorso di fallimento che non hai chiesto
```

Una scheda è **autoconsistente**: costruisce i presupposti che servono a capirla senza mandare il lettore a cercarli altrove, nemmeno per le cose semplici. La ripetizione fra schede diverse non è un difetto da eliminare ma ridondanza didattica voluta, perché chi arriva su una scheda ci arriva per quell'argomento e non ha letto le altre.

## I quattro modi in cui questo impianto si degrada, tutti osservati

Valgono più della convenzione stessa, perché la convenzione la si intuisce e questi no.

**Una scheda si stacca dal codice da sola, senza che nessuno sbagli.** Nel progetto di origine sei schede tecniche si sono trovate indietro di duecentodiciotto commit, ed era la **terza** occorrenza dopo due riallineamenti precedenti. La ripetizione è il dato: non è disattenzione, è che **il lavoro che invecchia una scheda è lo stesso lavoro che la rende utile**. Una scheda ferma non è neutra come un documento mancante, è peggio, perché chi la legge non sa di doverla verificare. Il presidio è il campo `covers-paths` più un riallineamento periodico dichiarato, non la buona volontà.

**Il racconto resta indietro rispetto ai fatti, un passo alla volta.** Sei passi registrati nel work-log e il racconto fermo alla voce precedente. La ragione è strutturale e va detta perché non è pigrizia: **ogni singolo passo sembra troppo piccolo per meritare una voce, e la somma di sei passi piccoli non lo è.** La decisione si prende sempre sul passo e mai sulla somma, quindi si rimanda sempre. Il presidio è `lint-didattica.py`, che non scrive la voce ma rende visibile il divario nel momento in cui si apre. Ammette esplicitamente la risposta "questo passo non ha prodotto una lezione", purché sia dichiarata: **il silenzio è l'unica cosa non ammessa**.

**Un indice scritto a mano diverge e nessuno se ne accorge.** Un elenco compilato a mano è una copia dei titoli, cioè una seconda fonte di verità: basta rinominare una scheda perché menta, e nessuna prova guarda un indice. Il presidio è `indice-refactor.py`, che lo genera dai file. Il principio generale è quello della matrice di tracciabilità: **ciò che si può derivare non si scrive**.

**Senza i percorsi dichiarati, l'invecchiamento diventa invisibile.** Nel progetto di origine cinquantatre schede su sessantuno non dichiaravano `covers-paths`, ed è emerso solo generando l'indice, che quella colonna la espone invece di nasconderla. Senza quel campo non si può porre la domanda "quali schede parlano di un file che è appena cambiato", che è l'unico modo meccanico di accorgersi che una spiegazione è diventata falsa. Da qui una regola sul disegno degli strumenti: **un generatore mostra i buchi invece di produrre un'uscita pulita**, perché l'uscita pulita è esattamente ciò che impedisce di vederli.

## Che cosa contiene il pacchetto

`templates/racconto.md` e `templates/scheda.md` sono gli scheletri delle due forme, da istanziare invece di ricostruirle a memoria. Il primo porta l'intestazione che dichiara scopo e modo di aggiornamento, l'indice delle voci e la struttura fissa in quattro parti, cioe contesto, com'era e perche era fragile, il salto e perche e meglio, e il rimando al dettaglio. Il secondo porta il front matter di riconciliazione, la nota di autoconsistenza e le sezioni che una scheda deve avere, fra cui due che si dimenticano sempre: le domande di dosaggio, cioe le decisioni che il principio non decide da solo, e che cosa protegge quella scelta dal tornare indietro, dove la risposta "niente" e un'informazione e non un'omissione.


`tools/indice-refactor.py` genera l'indice per argomento dai titoli e dal front matter delle schede. Predefiniti sulle convenzioni del progetto di origine, tutti sovrascrivibili.

```
python tools/indice-refactor.py
python tools/indice-refactor.py --cartella docs/studi --prefisso studio- --racconto RACCONTO.md
```

`tools/lint-didattica.py` segnala quando i fatti hanno superato le spiegazioni: voci di work-log senza didattica dichiarata, schede orfane che nessuna voce del racconto cita, e lo scarto in commit fra i due registri. **Porta tre costanti da adattare all'istanziazione**, in testa al file: il percorso del work-log, il percorso del racconto, e la data da cui la dichiarazione diventa obbligatoria. Quest'ultima esiste perché imporre una regola al passato produce solo rumore: si applica da quando si adotta.

## Quando offrirlo, e quando non offrirlo

Si offre a un progetto in cui qualcuno imparerà qualcosa rileggendo, e in cui il committente o l'autore hanno dichiarato di volere il ragionamento e non solo il risultato. Il caso tipico è un progetto lungo, seguito da una persona sola, la cui documentazione deve reggere a mesi di distanza o diventare materiale mostrabile.

**Non** si offre a un progetto breve, dove il work-log basta e un secondo registro diventa un obbligo che nessuno onora. E non si offre quando la documentazione ha un destinatario esterno che vuole istruzioni d'uso: quello è un manuale operativo, che risponde a "come faccio X" e non a "perché X è fatto così", ed è una tipologia di informazione diversa con un proprietario diverso. **Un registro che nessuno aggiorna è peggio della sua assenza, perché suggerisce una copertura che non c'è.**
