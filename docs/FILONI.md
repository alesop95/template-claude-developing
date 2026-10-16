# Filoni di sviluppo del template

> Indice dei filoni aperti, raccolti per tema. Un filone è una linea di indagine o di costruzione che non è ancora un pacchetto del catalogo: registra il mandato, che cosa è stato verificato e che cosa no, e il criterio con cui diventerà una voce di `.claude/templates/PACKAGES.md`. Finché resta qui non viene proposto a nessun progetto, perché il gate legge il catalogo e non questa cartella.

## Perché i filoni stanno fuori dal catalogo e fuori dalle regole

Il template fa ereditare uno strumento a un progetto in un modo solo: una riga nel catalogo, dentro il settore che il progetto riconosce dal proprio obiettivo, con un trigger concreto nella colonna "quando offrirlo", e il gate che la propone e chiede. Una voce di catalogo dichiara che lo strumento è stato guardato abbastanza da poterne dire che cosa fa, a chi serve e che cosa costa. Un filone è il passo prima: lo strumento è interessante, ma una o più di queste tre cose non sono ancora note, e proporlo oggi vorrebbe dire far decidere un progetto su affermazioni non verificate.

La seconda ragione è la guardia dei 100.000 caratteri. Il carico che ogni sessione paga all'avvio è fatto del `CLAUDE.md` e delle regole sotto `.claude/rules/`, e il template da solo ne vale 65.562 misurati il 2026-10-16 con `misura-istruzioni.py`, di cui 58.640 di regole sempre attive. Né questo indice né i documenti dei filoni stanno in quel perimetro: vivono sotto `docs/`, si leggono quando si lavora al filone, e non costano nulla a una sessione che non li apre. Ne discende il vincolo che vale per ogni filone fino al rilascio: un filone non aggiunge righe al `CLAUDE.md` e non scrive file sotto `.claude/rules/`. Quando un filone diventa un pacchetto che porta con sé una regola, il costo in caratteri di quella regola si misura e si dichiara nel catalogo accanto agli altri sei, così che il gate lo conti prima di proporlo invece di scoprirlo all'avvio della sessione successiva in un progetto già vicino alla soglia.

## Ciclo di vita di un filone

Un filone nasce con un documento in `docs/` che dichiara il mandato, la data e chi l'ha chiesto, il settore del catalogo a cui è destinato e il trigger con cui verrà proposto. Avanza registrando nel proprio documento ciò che è stato letto, provato o misurato, distinguendo sempre ciò che la fonte dichiara da ciò che è stato verificato. Si chiude in uno di tre modi: diventa una riga di catalogo, con o senza cartella sotto `.claude/templates/`; resta un'osservazione, quando non c'è niente da adottare ma l'idea va tenuta; oppure si archivia con la ragione, che è ciò che impedisce alla sessione successiva di rivalutarlo da capo. In tutti e tre i casi si aggiorna la sua riga qui sotto nello stesso giro.

## Indice per tema

| Tema | Filone | Stato | Settore di destinazione | Documento |
|---|---|---|---|---|
| Macchine e osservabilità | Pacchetto `linux-observability`: metriche, log e console locali per macchine Linux, senza abbonamenti | Specifica; pilota reale in corso nei progetti d'origine, pacchetto non rilasciato | Macchine e continuità operativa | `docs/progetto-pacchetto-linux-observability.md` |
| Modelli locali senza GPU | Inferenza di modelli MoE molto grandi su CPU con gli esperti letti dal disco (`colibri`), e dimensionamento di una macchina domestica da 16 o 32 GB | Aperto il 2026-10-16; fonti lette, nessuna prova eseguita | Da aprire: «Modelli locali e inferenza» | `docs/filone-llm-locali-senza-gpu.md` |
| Sicurezza informatica | Strumenti open source per l'assessment dei propri sistemi, per scopi etici: vulnerability assessment fatto in proprio come alternativa aperta a Nessus, poi log, risposta agli incidenti, hardening | Aperto il 2026-10-16; censite sei famiglie (scanner, log, risposta agli incidenti, basi di conoscenza, hardening Windows, telemetria), kit in quattro livelli, percorso di studio su roadmap.sh legato a un laboratorio locale; nessuno strumento provato | Da aprire: «Sicurezza informatica e assessment» | `docs/filone-cybersecurity.md`, tabelle in `docs/filone-cybersecurity-censimento.md` |
| Strumenti di lavoro degli agenti | Controllo di versione pensato per flussi agentici (Scion di Anthropic) e orchestrazione su Windows (Nimbalyst) | Nimbalyst catalogato il 2026-10-16; Scion osservazione, niente da adottare | Orchestrazione, sessioni e cataloghi di agenti | `docs/filone-strumenti-agentici.md` |

## Da dove arrivano i candidati

Le segnalazioni arrivano dal proprietario, dai progetti istanziati e dalle fonti di scouting, cioè i siti e gli elenchi che si ricontrollano ogni tanto. Le fonti e i candidati di ogni passaggio stanno in `docs/fonti-di-scouting.md`, con la data dell'ultimo controllo; un candidato che apre una linea nuova diventa un filone qui, uno che entra in un settore esistente va direttamente alle quattro domande.

## Che cosa un filone deve dire prima di entrare nel catalogo

Una voce di catalogo si scrive quando il filone sa rispondere a quattro domande con fonti lette e non con il riassunto di qualcun altro: che cosa fa lo strumento, misurato o almeno letto alla fonte primaria; a quale progetto serve, espresso come trigger che il gate possa verificare sui fatti del progetto; che cosa costa, compresi licenza, dipendenze, dati che escono dalla macchina e caratteri aggiunti al carico di avvio; e come si toglie. Un filone che sa rispondere alle prime due e non alle altre resta qui, e lo dice nella colonna dello stato.
