# Windows, WSL2, Docker Desktop e Linux nativo: quando usare cosa, e i limiti precisi

> Documento di riferimento del template. Serve ai pacchetti che allestiscono o misurano qualcosa su una macchina Windows, cioè `cyber-lab`, `llm-local`, `veeam-linux` e il filone `linux-observability`, e alla regola `.claude/rules/security-permissions.md`, che qui trova il dettaglio del perché su Windows nativo manca il sandbox. I fatti marcati «rilevato» vengono da una misura su questa macchina il 2026-10-16; gli altri sono conoscenza generale di WSL2 e Docker Desktop, da verificare sulla macchina specifica prima di farne una decisione irreversibile.

## La decisione in una frase

Su una macchina Windows si sceglie Linux nativo quando il carico ha bisogno di prestazioni di I/O o di rete vicine al metallo, o di isolamento a livello di sistema operativo che WSL non dà; si sceglie WSL2 quando serve un ambiente Linux integrato con i file e gli strumenti di Windows e il carico vive dentro il suo filesystem; si sceglie Docker Desktop quando servono container e lo si accetta sopra lo stesso motore WSL2, con i suoi limiti. Le tre opzioni non sono intercambiabili, e il resto del documento dice dove si rompono.

## Che cos'è WSL2, e i suoi limiti precisi

WSL2 non è un livello di compatibilità: è una vera macchina virtuale Linux leggera, con un kernel Microsoft, che gira sotto l'hypervisor di Windows. Su questa macchina il kernel rilevato è `6.18.33.2-microsoft-standard-WSL2`. Ne discendono limiti che contano quando si misura o si allestisce qualcosa.

La memoria è un tetto dinamico, non una quota fissa. Senza un file `.wslconfig` WSL2 prende fino a circa metà della RAM fisica: su questa macchina, 128 GB fisici, la macchina virtuale vede 62 GiB (rilevato, senza `.wslconfig`). La memoria si alloca a richiesta e in teoria si restituisce, ma in pratica la restituzione è parziale e tardiva, quindi un carico che tocca molta RAM la tiene occupata sul lato Windows finché non si fa `wsl --shutdown`. Per fissare un tetto diverso si scrive `[wsl2]\nmemory=NNGB` in `%USERPROFILE%\.wslconfig`, e ogni modifica richiede `wsl --shutdown` per avere effetto. Conseguenza per `llm-local`: non si limita la RAM di una prova cambiando `.wslconfig`, perché quel limite vale per l'intera macchina virtuale e ferma anche Docker Desktop, che vive nella stessa infrastruttura; si limita invece il solo processo con un gruppo di controllo.

Il filesystem ha due velocità molto diverse, ed è il limite che falsa più misure. Il disco della distribuzione è `ext4` su un disco virtuale, veloce, vicino al metallo: su questa macchina la radice è `/dev/sdf` di tipo `ext4` (rilevato). I dischi di Windows invece sono montati sotto `/mnt/c`, `/mnt/d` e simili attraverso il protocollo `9p` su `drvfs` (rilevato: `C:\ on /mnt/c type 9p`), con una dimensione di messaggio piccola: ogni operazione su un file lì attraversa un livello di traduzione fra i due sistemi, e un carico che legge o scrive molti file su `/mnt/c` può essere un ordine di grandezza più lento che sullo stesso carico in `ext4`. Da qui la regola che `llm-local` e il README di colibri impongono: il modello da misurare non sta su `/mnt/c`, sta nel filesystem ext4 della distribuzione, altrimenti la misura delle letture degli esperti dal disco misura la lentezza del 9p, non il modello. Il disco virtuale ext4 cresce da solo quando si riempie ma non si restringe quando si cancella: lo spazio liberato resta occupato sul lato Windows finché non si compatta il disco a mano con `wsl --shutdown` seguito da `diskpart` o `Optimize-VHD`.

systemd è ora supportato e su questa macchina è attivo (rilevato: `systemctl is-system-running` risponde `running`). Non era vero fino al 2022, e molti strumenti che danno per scontato systemd un tempo fallivano in WSL: oggi il tetto di memoria di un processo si impone con `systemd-run --user --scope -p MemoryMax=...`, che è la base del banco di `llm-local`. Dove systemd non fosse attivo si abilita con `[boot]\nsystemd=true` in `/etc/wsl.conf` e un riavvio della distribuzione.

La GPU paravirtualizzata è disponibile: il dispositivo `/dev/dxg` è presente (rilevato), ed è il canale con cui WSL2 espone la scheda grafica di Windows a CUDA o a DirectML dentro Linux. Su questa macchina la sola grafica è integrata Intel, quindi il canale c'è ma non serve a un motore CUDA; su una macchina con NVIDIA, WSL2 vede la GPU attraverso questo dispositivo senza che si installi un driver Linux, perché usa quello di Windows.

La rete ha due limiti pratici. In modalità NAT, quella predefinita, la macchina virtuale ha un indirizzo IP proprio su una rete interna e Windows inoltra `localhost` verso i servizi in ascolto dentro WSL, ma un servizio che ascolta solo su `127.0.0.1` dentro WSL non è sempre raggiungibile dall'esterno della macchina senza inoltro esplicito. La modalità a specchio, più recente, condivide le interfacce di Windows ed elimina parte di questi attriti, ma va abilitata e non è il default. E l'orologio della macchina virtuale può andare alla deriva dopo una sospensione di Windows, cosa che rompe le verifiche di certificati e i controlli basati sul tempo finché non si risincronizza.

Il limite che la regola sui permessi richiama è l'assenza di sandbox. Il sandbox di Claude Code, che isola a livello di sistema operativo ciò che i comandi di shell possono toccare, non è supportato su Windows nativo; la via pratica per averlo è proprio WSL2 con `bubblewrap`, oppure un container. Su Windows nativo, quindi, l'isolamento di un carico non fidato non c'è, ed è la ragione per cui `cyber-lab` vive dentro Docker e non sul sistema Windows direttamente.

## Che cos'è Docker Desktop su Windows, e i suoi limiti

Docker Desktop non è un secondo motore: su Windows gira sopra WSL2, in una propria distribuzione dedicata chiamata `docker-desktop` (rilevato nella sessione: `wsl -l -v` elenca `docker-desktop` in stato running accanto a `Ubuntu`). Ne seguono conseguenze precise. Tutti i container condividono la stessa macchina virtuale WSL2 e quindi lo stesso kernel e lo stesso tetto di memoria dinamico: un container che consuma molta RAM pesa sullo stesso serbatoio della distribuzione Ubuntu, e `cyber-lab` e un carico in Ubuntu competono per i 62 GiB. L'accesso ai file di Windows dai container passa per lo stesso livello `9p` lento, quindi un volume montato da `C:\` è lento allo stesso modo, mentre un volume Docker nativo vive nel disco della macchina virtuale ed è veloce. La GPU è disponibile ai container attraverso lo stesso `/dev/dxg`. L'integrazione con le distribuzioni WSL dell'utente è opzionale e va abilitata per usare il comando `docker` dentro Ubuntu, come su questa macchina.

C'è un limite non tecnico da conoscere: Docker Desktop è gratuito per uso personale, per l'istruzione e per le piccole organizzazioni, ma richiede una licenza a pagamento per le aziende sopra una certa soglia di dipendenti o di fatturato. Un progetto che gira in un'azienda grande non può dare per scontato Docker Desktop: la via libera da licenza è il motore Docker nativo dentro una distribuzione WSL2, installato a mano, senza l'applicazione Desktop.

## Che cosa dà il Linux nativo che le altre due non danno

Il Linux nativo è la linea di base, e le due opzioni Windows si misurano rispetto a esso. Dà prestazioni di I/O su disco e di rete vicine al metallo, senza il livello `9p` e senza l'hypervisor; dà l'isolamento a livello di sistema operativo completo, con `bubblewrap`, i namespace e i gruppi di controllo senza le limitazioni della macchina virtuale; dà un orologio che non va alla deriva dopo la sospensione; dà il controllo diretto del kernel e dei suoi moduli, che conta per `veeam-linux`, dove la scelta della variante con o senza modulo del kernel decide se si ottiene un'immagine avviabile. Un carico che ha bisogno di una di queste quattro cose non si sposta su WSL senza perderle, e la perdita va dichiarata invece di scoprirla a misura fatta.

## Tabella dei limiti

| Aspetto | Linux nativo | WSL2 | Docker Desktop (su WSL2) |
|---|---|---|---|
| Memoria | fisica, tutta | tetto dinamico, circa metà della RAM senza `.wslconfig` (62 GiB su 128 qui) | stesso tetto della macchina virtuale WSL2, condiviso |
| I/O su disco proprio | nativo | veloce su `ext4` della distribuzione | veloce su volumi Docker nativi |
| I/O su disco Windows | non applicabile | lento, livello `9p` su `/mnt/c` | lento, stesso livello su volumi montati da `C:\` |
| systemd | sì | sì se abilitato (attivo qui) | nella distribuzione `docker-desktop`, non gestito dall'utente |
| GPU | diretta | via `/dev/dxg`, driver di Windows | via `/dev/dxg` |
| Sandbox di Claude Code | sì, con bubblewrap | sì, con bubblewrap | isolamento dei container, non il sandbox di sessione |
| Orologio dopo sospensione | stabile | può andare alla deriva | come WSL2 |
| Licenza | nessuna | nessuna | gratuito solo sotto soglia aziendale |

## Conseguenze per i pacchetti del template

Per `llm-local` la misura vive in `ext4` dentro WSL, non su `/mnt/c`, e il limite di RAM si impone con il gruppo di controllo del processo e non con `.wslconfig`. Per `cyber-lab` il laboratorio sta in Docker perché su Windows nativo non c'è sandbox, e i suoi volumi stanno nel disco della macchina virtuale e non montati da `C:\`, sia per la velocità sia perché così restano confinati. Per `veeam-linux` la scelta della variante del pacchetto dipende dal controllo del kernel, che il Linux nativo dà e WSL limita, quindi un backup a livello di volume si prova sul Linux reale e non in WSL. Per il filone `linux-observability` una macchina misurata dentro WSL non è la stessa macchina misurata nativa, e il perimetro della misura lo deve dire.
