# Filone: modelli linguistici locali senza GPU

> Aperto il 2026-10-16 su richiesta del proprietario. La domanda che lo governa, precisata il 2026-10-16, è una sola: è realistico avere su una macchina un modello locale che faccia il lavoro meccanico senza consumare token di Claude, quando si istanzia un progetto con il template. La domanda dei 16 o 32 GB di RAM è un sotto-problema di questa. Stato: fonti lette, scaffold di prova scritto, nessuna misura eseguita. Indice dei filoni in `docs/FILONI.md`.

## Il mandato

La domanda non è usare un modello enorme per sé, ma scaricare dal conto di Claude il lavoro che non ha bisogno del suo giudizio. Il template dice già, nella regola `token-economy.md` e in `instradamento-modelli`, che il lavoro meccanico va al modello più economico che lo sa fare e che il modello capace si riserva alla conversazione principale. Un modello locale è il gradino più economico possibile, perché costa corrente e non token: cercare dove sta qualcosa in un repository, estrarre lo stesso dato da molti file, classificare molti elementi su etichette chiuse, convertire, contare. Se una macchina può fare questo da sé, i token di Claude restano per la parte che li merita.

Il proprietario segnala `colibri` (repository `JustVugg/colibri`, autore italiano) come motore per far girare modelli grandi su CPU senza scheda grafica. Il filone verifica se colibri, o uno strumento simile, regga quel ruolo, e con quale qualità e velocità sull'hardware reale.

## La fattibilità, e dove sta il confine

Il punto che decide la realizzabilità non è se un modello giri, ma come un agente lo chiama. Qui la fonte primaria dà una conferma forte, letta il 2026-10-16 nel repository clonato, in `docs/api.md`: `coli serve` tiene un modello caricato ed espone un endpoint compatibile con quello di OpenAI, `http://127.0.0.1:8000/v1/chat/completions`, e anche uno compatibile con quello di Anthropic, `/v1/messages` con `ANTHROPIC_BASE_URL`. Un modello locale si presenta quindi a uno script o a un agente esattamente come un'API in cloud, e il repository porta anche un harness ufficiale di misura, `c/tools/benchmark_http_serving.py`, che interroga quell'endpoint e registra token, durata e tempo al primo token. Da questa conferma si aprono due usi, con un confine netto fra loro.

Il primo uso è realistico e utile da subito: il lavoro meccanico a lotti non passa da un agente conversazionale ma da uno script che manda i molti elementi al servizio locale e ne raccoglie le risposte, esattamente il modello del pacchetto `lavoro-a-lotti`. Quegli elementi non entrano mai nel contesto di Claude, quindi non costano token, e la qualità richiesta è bassa perché il compito si verifica su una regola. Un modello piccolo a esperti, come Qwen3-Coder-30B-A3B o Qwen3.6, che l'autore misura fra sei e ventitré parole al secondo su CPU con RAM sufficiente, è adatto a questo: non serve che sia interattivo, serve che macini un lotto mentre si lavora ad altro.

Il secondo uso non è realistico oggi, e va detto per non prometterlo: sostituire Claude nella conversazione principale di Claude Code. I subagent di Claude Code girano su modelli Anthropic e non si puntano a un servizio locale, e la qualità di un modello che gira su CPU di casa non regge i passi su cui si appoggia il passo successivo, che è proprio ciò che `token-economy.md` vieta di delegare. Un altro agente da terminale che accetti un endpoint compatibile con OpenAI, come Codex, potrebbe puntare al modello locale, ma resta la questione della qualità.

La risposta breve alla domanda del proprietario è quindi: sì, è realistico per il lavoro meccanico a lotti, come servizio locale che uno script interroga al posto di Claude; no, come sostituto della conversazione principale. Il valore per il template è il primo, e la prova di cui il filone ha bisogno lo misura direttamente: non solo le parole al secondo, ma se un lotto reale, per esempio classificare o inventariare molti file, esca corretto da un modello piccolo in locale. Questa è la misura che chiude il filone, più della velocità pura.

## Le due uscite possibili

Il filone ha due uscite. Un pacchetto del template che espone un modello locale come servizio e dà lo script che gli manda i lotti, instradando a esso il lavoro meccanico invece che a un subagent: è l'uscita che risponde alla domanda del proprietario. Oppure, se la prova dice che la qualità non regge nemmeno il lavoro meccanico, una scheda che lo documenta come non ancora praticabile e dice a quali condizioni lo diventerà. In entrambi i casi il pacchetto `llm-local` qui sotto, con il banco di prova, è il passo che produce la misura su cui si decide.

## Che cosa è lo strumento, secondo la fonte

Lettura del 2026-10-16 del `README.md` del repository, attraverso uno strumento di recupero che riassume la pagina: i numeri qui sotto sono quindi di seconda mano rispetto al testo originale e vanno riletti alla fonte prima di diventare una voce di catalogo.

`colibri` è un motore di inferenza scritto in C senza dipendenze, dedicato ai modelli *mixture-of-experts*[^1], quelli in cui per ogni token lavora solo una piccola parte dei pesi. La parte densa del modello, cioè attenzione, esperto condiviso ed embedding, resta in RAM; gli esperti instradati restano su disco e si leggono quando il router li chiede, attraverso una cache che impara quali si usano di più. La scheda grafica è facoltativa, con CUDA, Vulkan o Metal, e serve a tenere in memoria veloce gli esperti più frequenti. Il README afferma che la posizione dei pesi cambia la velocità e non il risultato. Per compilare servono gcc o clang con OpenMP; Python serve solo per il lanciatore, il convertitore e il gateway API. Gira su Linux, macOS e Windows, dove si avvia da `START-HERE.bat`. Licenza Apache 2.0, copyright 2026 Vincenzo Fornaro; i modelli conservano le proprie licenze, e almeno uno di quelli elencati è solo per uso non commerciale.

I requisiti dichiarati sono 8 GB di RAM come minimo, 16 o più consigliati, e 22 GB di disco per il modello più piccolo; i modelli grandi vanno da 85 GB a 1,56 TB su disco.

## La domanda dei 16 o 32 GB

La tecnica sposta il collo di bottiglia dalla RAM al disco, e questo cambia la domanda. Con gli esperti letti dal disco un modello gigantesco parte anche con poca memoria, ma ogni esperto che non sta in cache è una lettura da NVMe, quindi la RAM non decide se il modello gira ma quanto spesso si torna al disco, cioè la velocità.

Dalle tabelle del README, con la RAM minima per partire e quella con cui l'autore ha misurato:

| Modello | Disco | RAM minima / misurata | Velocità dichiarata in decodifica |
|---|---|---|---|
| OLMoE | 14 GB | 8 / 8 GB | 22-23 token/s su CPU |
| Qwen3-Coder-30B-A3B | 19 GB | 8 / 18 GB | 8,5-9,6 token/s su CPU, esperti tutti in RAM |
| Qwen3.6-35B-A3B | 23 GB | 10 / 20 GB | 6,0 su CPU; 9,9 con iGPU Radeon 780M |
| DeepSeek V4 Flash | 167 GB | 16 / 32 GB | 0,93 token/s con 32 GB, 1,24 con 63 GB, solo CPU |
| GLM-5.2 | 429 GB | 16 / 24 GB | 1,83 con 128 GB; 0,05-0,1 a freddo su un portatile da 25 GB |
| MiMo-V2.6 Flash | 172 GB | 32 / 52 GB | non riportata nel riassunto |

Ne segue una lettura in due parti, e la seconda è un'inferenza da verificare. Con 16 GB girano a velocità utilizzabile i modelli piccoli, da 14 a 23 GB su disco, e per Qwen3-Coder la misura dell'autore è con 18 GB, quindi a 16 una parte degli esperti tornerebbe sul disco. I modelli grandi partono anche a 16 GB, ma il README non riporta nessuna misura a 16 GB su un modello grande, e l'unica misura vicina, GLM-5.2 a freddo su 25 GB, dà un decimo di token al secondo, cioè nessun uso interattivo. Con 32 GB si raggiungono le condizioni misurate di DeepSeek V4 Flash, dove però 0,93 token al secondo resta adatto a un lavoro in differita e non a una conversazione. La mia inferenza, non verificata, è che 32 GB conviene se l'obiettivo sono i modelli piccoli con margine per il sistema e per un secondo programma aperto, mentre per usare davvero i modelli grandi decide più il disco NVMe che il passaggio da 16 a 32. Va misurata su una macchina reale prima di comprare.

## Che cosa resta da verificare

Il numero di stelle riportato, circa 42.000, è insolito per un progetto con copyright 2026 e va guardato nella cronologia prima di usarlo come indice di maturità. Mancano la data dell'ultimo commit e il numero della release corrente. Tutte le velocità sono dichiarate dall'autore su macchine sue, senza repliche indipendenti. Non è stato letto il codice e non è stata eseguita nessuna prova.

## Dove e come si misura

La macchina di lavoro su cui gira questa sessione è più grande di entrambe le configurazioni da confrontare, e per questo è il posto giusto per misurarle: rilievo in sola lettura del 2026-10-16, 128 GB di DDR5 a 5600 MT/s in quattro moduli da 32, CPU Intel Core i7-14700 con 20 core e 28 thread, NVMe Crucial P3 da 1 TB con 338 GB liberi sul volume di sistema, nessuna GPU dedicata, WSL2 con Ubuntu e Docker Desktop. Non si toglie memoria fisica alla macchina: si limita quella che il motore può usare, prima a 16 e poi a 32 GB, e si misura lo stesso modello nelle due condizioni. Il limite deve contare anche la cache dei file, perché è lì che restano gli esperti letti dal disco, e un limite che contasse solo la memoria privata del processo misurerebbe una macchina da 128 GB travestita.

Il magazzino stabile dei modelli è la cartella di macchina `C:/colibri-models/`, creata il 2026-10-16 e documentata nel suo `LEGGIMI.md`, scelta dal proprietario perché sopravvive a `wsl --shutdown` e a una reinstallazione della distribuzione. La corsa di misura lavora però su una copia nel filesystem ext4 della distribuzione, perché il README di colibri chiede di tenere il modello fuori da `/mnt/c` quando il motore gira dentro WSL: l'accesso al disco Windows attraverso il livello di traduzione falserebbe la misura delle letture degli esperti dal disco. La copia si fa una volta per modello.

Il percorso scelto è Linux dentro WSL2, perché il README documenta lì la compilazione e gli strumenti di diagnosi. Rilievo del 2026-10-16 sulla distribuzione Ubuntu: 28 CPU viste, 62 GB di RAM nella macchina virtuale, `systemd` attivo e `systemd-run` presente, disco ext4 con 948 GB liberi sull'NVMe, `git` presente mentre `gcc` e `make` vanno installati prima di compilare. Il limite di memoria si applica quindi al solo processo del motore con un gruppo di controllo, `systemd-run --user --scope -p MemoryMax=16G`, che conta anche la cache dei file; i 62 GB della macchina virtuale lasciano margine sopra il tetto di 32 GB. L'alternativa del limite globale in `.wslconfig` si scarta perché fermerebbe anche Docker Desktop, che vive nella stessa infrastruttura, e richiede `wsl --shutdown` a ogni cambio.

Il protocollo, da allineare al protocollo del repository, https://github.com/JustVugg/colibri/blob/main/docs/benchmarking.md, prima di eseguirlo: compilazione con `./start-here.sh`, poi `./coli doctor` in sola lettura e `./coli plan`, che dice dove vivrà ogni parte del modello; `./coli tune` una volta per configurazione, perché sceglie le impostazioni in base alla memoria che vede; per ogni modello e per ogni limite, tre corse con lo stesso prompt, cache dei file svuotata prima della prima, registrando token al secondo in decodifica, memoria massima del gruppo di controllo e byte letti dal disco. La variabile `DIRECT=1`, che legge gli esperti saltando la cache dei file, si prova a parte perché il README la dichiara utile su NVMe veloci e neutra o peggiore su altri dischi.

I modelli proposti sono due: Qwen3.6-35B-A3B, 23 GB, il più piccolo con misure dell'autore su CPU, che dice se a 16 GB il caso d'uso quotidiano regge; e DeepSeek V4 Flash, 167 GB, misurato dall'autore con 32 GB, che dice se a 32 GB un modello grande è utilizzabile e quanto perde a 16. Insieme occupano circa 190 GB sui 338 liberi, e lo scaricamento richiede ore. Il risultato vale per questa CPU e questo disco; per trasferirlo alla macchina di casa servono il modello di CPU, il tipo di RAM e il disco di quella macchina, perché la velocità a parità di memoria dipende da entrambi.

## Stato della prova

Rilievo del 2026-10-19. colibri è stato compilato davvero sulla macchina di sviluppo: dentro WSL, dopo `apt-get install build-essential`, `./setup.sh` ha riconosciuto gcc 13 su 28 core con OpenMP, e `make olmoe` ha prodotto il binario del motore. Il collaudo della catena è partito dal modello più piccolo, OLMoE, convertito dal repository HuggingFace `allenai/OLMoE-1B-7B-0125-Instruct` con `c/tools/convert_olmoe_merged.py` nel formato a int8 di colibri, 7,0 GB su disco; la velocità verso HuggingFace misurata lo stesso giorno è circa 7 MB al secondo, quindi lo scaricamento è durato pochi minuti, mentre il mirror APT di Ubuntu era molto più lento per un problema del mirror e non della connessione.

La catena funziona end-to-end su CPU e senza scheda grafica. `coli run` ha caricato il modello in 0,7 secondi con 1,79 GB residenti e ha generato italiano coerente. Il pacchetto `llm-local` è stato collaudato per intero sulla macchina: il banco di velocità avvia `coli serve` sotto un gruppo di controllo e lo misura con l'harness ufficiale, e il banco di correttezza interroga l'endpoint con un lotto a risposta nota. Le due misure, con OLMoE e un tetto di 16 GB, dicono due cose opposte. La velocità è buona: 15,7 token al secondo in decodifica, con la memoria del processo tenuta a 15,45 GB sotto il tetto dal gruppo di controllo. La correttezza è pessima: su dodici nomi di file da classificare in quattro etichette chiuse, OLMoE ne ha azzeccati due, cioè il 16,7 per cento, rispondendo quasi sempre «dati». È la prova sul campo di ciò che il filone sosteneva in astratto: il surrogato comodo, i token al secondo, diceva che il modello è adatto; la misura che decide, la correttezza, dice che non lo è. Con OLMoE l'offload non scarica lavoro, lo sposta.

La conclusione non è che l'offload sia irrealizzabile, ma che OLMoE è troppo piccolo per il lavoro meccanico, ed era solo il collaudo della catena. La catena è provata e i due banchi funzionano; resta da misurare un modello costruito per questo, cioè Qwen3-Coder-30B-A3B o Qwen3.6, sullo stesso lotto. Il filone si chiude quando uno di quei modelli avrà una correttezza abbastanza alta da rendere l'offload conveniente, oppure, se nessuno la raggiunge su questa macchina, con la scheda che lo documenta come non ancora praticabile. Questo è un risultato intermedio, non la chiusura.

## Alternative da confrontare

Il passaggio di scouting del 2026-10-16, registrato in `docs/fonti-di-scouting.md`, ha segnalato `b4rtaz/distributed-llama`, licenza MIT, che affronta lo stesso problema dall'altro lato: invece di leggere gli esperti dal disco divide il modello fra più macchine domestiche collegate in rete, sommando le loro CPU e la loro RAM. Non è stato letto oltre i metadati del repository. Se la domanda di casa diventa «due macchine da 16 GB o una da 32», è lo strumento da misurare accanto a colibri.

## Destinazione nel catalogo

Se il filone diventa pacchetto, il settore oggi non esiste: nessuno degli altri dodici lo accoglie senza forzature, perché un progetto lo cercherebbe partendo dall'obiettivo di tenere un modello in locale. Il settore proposto è «Modelli locali e inferenza», riconosciuto dalla domanda se il progetto debba elaborare materiale che non può uscire dalla macchina, o lavorare senza rete. Un pacchetto di questo settore non porta regole sotto `.claude/rules/`, quindi non pesa sulla guardia dei 100.000 caratteri; il suo costo reale sta nel disco, nella RAM e nella licenza del modello scelto. Va anche messo accanto al pilota Ollama già documentato in `docs/progetto-pacchetto-linux-observability.md`, perché due modi di far girare un modello locale nello stesso catalogo vanno distinti dal trigger e non lasciati alla scelta del gate.

[^1]: *Mixture-of-experts*, architettura in cui il modello è diviso in molti sottomodelli, detti esperti, e un router ne attiva pochi per ogni token: il modello è grande su disco ma ogni passo ne usa una frazione.
