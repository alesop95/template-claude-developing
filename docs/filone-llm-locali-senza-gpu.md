# Filone: modelli linguistici locali senza GPU

> Aperto il 2026-10-16 su richiesta del proprietario, con la domanda pratica se una macchina domestica da 16 o da 32 GB di RAM basti a usare lo strumento. Stato: fonti lette, nessuna prova eseguita, nessun pacchetto. Indice dei filoni in `docs/FILONI.md`.

## Il mandato

Il proprietario segnala `colibri` (repository `JustVugg/colibri`, sviluppato da un autore italiano) come strumento per far girare modelli linguistici molto grandi sui computer già in uso, senza scheda grafica, e chiede di capire se per casa convengano 16 o 32 GB di RAM componibili. Il filone ha due uscite possibili: un pacchetto del template che offra un modello locale ai progetti che ne hanno bisogno, per esempio per tenere dentro la macchina materiale che non deve uscire, oppure una scheda di dimensionamento per la macchina domestica, che appartiene a un progetto di macchina e non al template.

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

Il percorso scelto è Linux dentro WSL2, perché il README documenta lì la compilazione e gli strumenti di diagnosi, e chiede esplicitamente di tenere il modello fuori da `/mnt/c`: i file del modello vanno nel filesystem ext4 della distribuzione, che sta comunque sull'NVMe. Il limite di memoria si applica al solo processo del motore con un gruppo di controllo, per esempio `systemd-run --user --scope -p MemoryMax=16G`, che conta anche la cache dei file; è da verificare che la distribuzione abbia systemd attivo. L'alternativa è il limite globale della macchina virtuale in `.wslconfig`, che però ferma anche Docker Desktop, che vive nella stessa infrastruttura, e richiede `wsl --shutdown` a ogni cambio.

Il protocollo, da allineare al protocollo del repository, https://github.com/JustVugg/colibri/blob/main/docs/benchmarking.md, prima di eseguirlo: compilazione con `./start-here.sh`, poi `./coli doctor` in sola lettura e `./coli plan`, che dice dove vivrà ogni parte del modello; `./coli tune` una volta per configurazione, perché sceglie le impostazioni in base alla memoria che vede; per ogni modello e per ogni limite, tre corse con lo stesso prompt, cache dei file svuotata prima della prima, registrando token al secondo in decodifica, memoria massima del gruppo di controllo e byte letti dal disco. La variabile `DIRECT=1`, che legge gli esperti saltando la cache dei file, si prova a parte perché il README la dichiara utile su NVMe veloci e neutra o peggiore su altri dischi.

I modelli proposti sono due: Qwen3.6-35B-A3B, 23 GB, il più piccolo con misure dell'autore su CPU, che dice se a 16 GB il caso d'uso quotidiano regge; e DeepSeek V4 Flash, 167 GB, misurato dall'autore con 32 GB, che dice se a 32 GB un modello grande è utilizzabile e quanto perde a 16. Insieme occupano circa 190 GB sui 338 liberi, e lo scaricamento richiede ore. La prova non è stata eseguita: aspetta il via del proprietario sul download e sul disco da usare. Il risultato vale per questa CPU e questo disco; per trasferirlo alla macchina di casa servono il modello di CPU, il tipo di RAM e il disco di quella macchina, perché la velocità a parità di memoria dipende da entrambi.

## Alternative da confrontare

Il passaggio di scouting del 2026-10-16, registrato in `docs/fonti-di-scouting.md`, ha segnalato `b4rtaz/distributed-llama`, licenza MIT, che affronta lo stesso problema dall'altro lato: invece di leggere gli esperti dal disco divide il modello fra più macchine domestiche collegate in rete, sommando le loro CPU e la loro RAM. Non è stato letto oltre i metadati del repository. Se la domanda di casa diventa «due macchine da 16 GB o una da 32», è lo strumento da misurare accanto a colibri.

## Destinazione nel catalogo

Se il filone diventa pacchetto, il settore oggi non esiste: nessuno degli altri dodici lo accoglie senza forzature, perché un progetto lo cercherebbe partendo dall'obiettivo di tenere un modello in locale. Il settore proposto è «Modelli locali e inferenza», riconosciuto dalla domanda se il progetto debba elaborare materiale che non può uscire dalla macchina, o lavorare senza rete. Un pacchetto di questo settore non porta regole sotto `.claude/rules/`, quindi non pesa sulla guardia dei 100.000 caratteri; il suo costo reale sta nel disco, nella RAM e nella licenza del modello scelto. Va anche messo accanto al pilota Ollama già documentato in `docs/progetto-pacchetto-linux-observability.md`, perché due modi di far girare un modello locale nello stesso catalogo vanno distinti dal trigger e non lasciati alla scelta del gate.

[^1]: *Mixture-of-experts*, architettura in cui il modello è diviso in molti sottomodelli, detti esperti, e un router ne attiva pochi per ogni token: il modello è grande su disco ma ogni passo ne usa una frazione.
