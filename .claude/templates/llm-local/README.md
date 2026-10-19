# Pacchetto opzionale `llm-local`

<!-- readme-summary: far girare e misurare un modello linguistico in locale su CPU con colibri, con un banco di prova portabile che limita la RAM e registra velocità, memoria e letture dal disco -->

> Fa girare un modello linguistico in locale, su CPU e senza scheda grafica, con il motore colibri, come servizio che uno script interroga per il lavoro meccanico a lotti al posto di un agente a pagamento. Il banco di prova risponde a due domande: quanta RAM serve a questa macchina per un dato modello, e se il lavoro meccanico esce corretto da un modello piccolo in locale. È parametrizzato e portabile, così lo stesso studio si rifà su un'altra macchina cambiando un file di valori. Settore del catalogo: «Modelli locali e inferenza». Stato: scaffold scritto il 2026-10-16, non ancora eseguito; il filone che lo motiva è `docs/filone-llm-locali-senza-gpu.md` del template.

## A chi serve

A un progetto che vuole scaricare dal conto dei token il lavoro meccanico, cioè cercare, estrarre, classificare, convertire e contare su molti elementi, mandandolo a un modello locale che costa corrente invece che token. E a un progetto che deve elaborare materiale che non può uscire dalla macchina o lavorare senza rete. Non serve a chi vuole un sostituto della conversazione principale: quella resta sul modello capace, perché un modello su CPU di casa non regge i passi su cui si appoggia il passo successivo, che la regola `token-economy.md` vieta di delegare.

## Che cosa istanzia

Nel progetto che lo adotta scaffolda `tools/bench-colibri.sh`, il banco di prova, e `llm-local.valori.esempio.sh`, il file dei parametri da copiare in `llm-local.valori.sh` (ignorato da git) e compilare con i percorsi reali. Non scarica modelli e non installa colibri: sono passi espliciti, perché un modello pesa decine o centinaia di gigabyte e l'installazione tocca la macchina.

## Perché colibri e perché misurare

colibri tiene su disco la parte a esperti di un modello e la legge quando serve, quindi un modello enorme parte anche con poca RAM. Ne segue che la RAM non decide se il modello gira ma quanto spesso il motore torna al disco, cioè la velocità, e questo si vede solo misurando sulla macchina vera. Il banco prende lo stesso modello con due tetti di RAM diversi e registra, per ciascuno, le parole al secondo in decodifica, la memoria massima e i byte letti dal disco.

La scelta dei modelli con cui si misura dipende dalla domanda. Per decidere fra due tagli di RAM si prende un modello piccolo, che dice se il taglio basso regge il lavoro quotidiano, e un modello grande misurato dall'autore proprio a quei tagli, che dice che cosa si guadagna salendo. La spiegazione estesa, con i due modelli scelti per il collaudo su questa macchina, sta in `C:/colibri-models/LEGGIMI.md` sulla macchina di sviluppo e nel filone.

## Come si limita la RAM senza toglierla alla macchina

Non si cambia la RAM fisica e non si cambia il tetto globale di WSL, che fermerebbe anche altro. Si limita il solo processo del motore con un gruppo di controllo, e il tetto deve contare anche la cache dei file, perché è lì che restano gli esperti letti dal disco: un tetto che contasse solo la memoria privata misurerebbe una macchina grande travestita da piccola. Su Linux con systemd il banco usa `systemd-run --user --scope -p MemoryMax=<tetto>`, verificato disponibile sulla macchina di sviluppo il 2026-10-16.

## Recap d'uso

Prerequisiti: colibri compilato (su Linux `gcc`, `make`, OpenMP e `git`), un modello già scaricato in una cartella su disco veloce, e, dentro WSL, il modello fuori da `/mnt/c`. Poi si copia il file dei valori e si lancia il banco una volta per tetto di RAM.

```bash
cp llm-local.valori.esempio.sh llm-local.valori.sh
# si compila llm-local.valori.sh con i percorsi reali
bash tools/bench-colibri.sh --valori llm-local.valori.sh --modello qwen36 --ram 16G
bash tools/bench-colibri.sh --valori llm-local.valori.sh --modello qwen36 --ram 32G
```

Ogni corsa scrive una riga nella cartella delle misure indicata dai valori, con data, modello, tetto, parole al secondo, memoria massima e byte letti. Il confronto fra le righe a 16 e a 32 è la risposta.

## Portare lo stesso studio su un'altra macchina

Il banco non ha dentro nessun percorso né nessun numero di questa macchina: tutto sta nel file dei valori. Su un'altra macchina si installa colibri, si scarica il modello, si copia il file dei valori e lo si ricompila con i percorsi di là, e si rilancia. L'esito vale per la CPU e il disco di quella macchina, e il banco lo registra accanto alla misura, perché una velocità senza l'hardware su cui è stata presa non si confronta.

## La misura che conta davvero

La velocità è metà della risposta. L'altra metà è se il lavoro meccanico esce corretto da un modello piccolo: un banco che misurasse solo le parole al secondo direbbe che il modello è veloce, non che è utile. La prova che chiude il filone prende un lotto reale e verificabile, per esempio classificare un insieme di file su etichette chiuse di cui si conosce già la risposta giusta, lo manda al modello locale e conta quante risposte sono esatte. Un modello che macina veloce ma sbaglia una classificazione su cinque non scarica lavoro da Claude: lo sposta soltanto, e la correzione costa più del risparmio. Questo secondo banco va accanto a `bench-colibri.sh` e usa lo stesso servizio locale.

## Come misura, e che cosa è confermato

Il banco non reinventa la misura: tiene il server `coli serve` sotto il tetto di RAM con il gruppo di controllo, e lo interroga con l'harness ufficiale del repository, `c/tools/benchmark_http_serving.py`, che produce un rapporto con token, durata e tempo al primo token. L'endpoint è compatibile con quello di OpenAI, e colibri ne espone anche uno compatibile con quello di Anthropic: confermato alla fonte il 2026-10-16 in `docs/api.md` del repository clonato. È questo che rende reale l'offload del lavoro meccanico, perché uno script interroga il modello locale come interrogherebbe un'API in cloud.

## Stato del collaudo

La catena è stata provata per intero il 2026-10-19 su una macchina Windows con WSL, su CPU e senza scheda grafica, con il modello OLMoE. I due banchi funzionano: `bench-colibri.sh` ha avviato `coli serve` sotto il gruppo di controllo e l'ha misurato con l'harness ufficiale, dando 15,7 token al secondo con la memoria tenuta sotto il tetto di 16 GB; `bench-correttezza.py` ha interrogato l'endpoint con un lotto di classificazione a risposta nota, dando una correttezza del 16,7 per cento. Il secondo numero è la ragione per cui OLMoE non serve all'offload: è troppo piccolo, e andava solo a collaudare la catena. Il pacchetto è quindi validato come pipeline; ciò che resta aperto è la scelta di un modello abbastanza accurato, da misurare sullo stesso lotto, tipicamente Qwen3-Coder-30B-A3B o Qwen3.6. Il dettaglio sta in `docs/filone-llm-locali-senza-gpu.md` del template.

## Limiti dichiarati

La pipeline è provata, ma nessun modello adatto all'offload reale è ancora stato validato: finché un modello non supera la correttezza che il progetto richiede, questo pacchetto dà gli strumenti per misurare, non un modello pronto da usare. Perché la misura dentro WSL non sia falsata dal filesystem lento e dal tetto di RAM dinamico, vale quanto scritto in `docs/windows-docker-wsl-vs-linux.md` del template. Perché la misura dentro WSL non sia falsata dal filesystem lento e dal tetto di RAM dinamico, vale quanto scritto in `docs/windows-docker-wsl-vs-linux.md` del template.
