# Filone cybersecurity: framework di governance e percorso di studio

> Secondo allegato di `docs/filone-cybersecurity.md`. Lega gli strumenti del censimento a un framework riconosciuto, il NIST Cybersecurity Framework 2.0, e disegna il percorso per diventare esperti ancorandolo alle certificazioni. La struttura dei domini viene dal corpus di studio del proprietario su Proton Drive, mappato il 2026-10-16 per sola struttura: nessun contenuto di libri o di documenti personali è stato letto o copiato, e il corpus resta una fonte personale, non un materiale ingerito dal template.

## Perché un framework, e non solo strumenti

Un elenco di strumenti dice che cosa si può fare, non in quale ordine né perché. Il NIST Cybersecurity Framework 2.0 dà quell'ordine con sei funzioni, e il proprietario lo ha già studiato come questionario di autovalutazione, una scheda per funzione. Agganciare a quelle sei funzioni le famiglie di strumenti del censimento trasforma il kit in un programma: ogni funzione ha la sua domanda, i suoi strumenti e il suo esercizio di laboratorio. Le sei funzioni sono Govern, Identify, Protect, Detect, Respond, Recover; Govern è la funzione aggiunta dalla versione 2.0 e tiene insieme le altre cinque stabilendo strategia, aspettative e politiche di gestione del rischio.

## Le funzioni, e gli strumenti che le servono

| Funzione NIST CSF 2.0 | La domanda | Che cosa serve su un sistema proprio | Strumenti dal censimento |
|---|---|---|---|
| Govern | Chi decide, con quali politiche e verso quali obblighi | Un inventario delle politiche e la mappa degli obblighi di legge; su un sistema proprio è leggero, su un'organizzazione pesa | Non è un settore di strumenti ma di documenti: NIST CSF come questionario, NIS2 e ISO 27001 come riferimenti normativi |
| Identify | Che cosa possiedo e che cosa è debole | Inventario di macchine, servizi e dipendenze, e l'elenco delle vulnerabilità note | Nmap per l'inventario, Greenbone e Nuclei per le vulnerabilità di rete, OSV-Scanner e Trivy per le dipendenze del software |
| Protect | La macchina è configurata bene | Hardening misurato prima e dopo, e gestione delle identità | HardeningKitty con le baseline del Security Compliance Toolkit su Windows, Lynis e OpenSCAP su Linux, Windows LAPS per le password locali |
| Detect | Mi accorgo se succede qualcosa | Una memoria degli eventi e un occhio sui log | Sysmon con sysmon-modular, le regole Sigma, Wazuh come vista centrale, Suricata o Zeek dove si osserva il traffico |
| Respond | So che cosa fare quando succede | Lettura rapida dei log eventi e raccolta di prove | Hayabusa e Chainsaw sui log di Windows, Velociraptor per raccogliere artefatti, YARA per riconoscere i file |
| Recover | So rimettere in piedi | Backup verificati e ricostruzione | Appoggiati ai pacchetti `veeam-linux` e al filone `linux-observability`, e su Windows a `windows-status` |

La priorità dei risultati, cioè da che cosa cominciare a correggere, non è una funzione a sé ma attraversa Identify e Protect, e si fa con i tre elenchi pubblici KEV, EPSS e CVSS descritti nel primo allegato. Recover non introduce strumenti nuovi perché il template ha già la continuità operativa come settore proprio: il filone cybersecurity la richiama invece di duplicarla.

## Il percorso di studio, ancorato alle certificazioni

Il proprietario studia la materia su tre assi che il corpus rende espliciti: lo studio da libri e corsi ripartito per tema, il percorso verso le certificazioni e la governance per framework. Il filone propone un ordine che unisce i tre assi e li lega al laboratorio, perché la competenza si costruisce usando gli strumenti su sistemi propri.

Il primo gradino è la base e corrisponde alla certificazione CompTIA Security+, che il proprietario sta preparando: copre reti, minacce, crittografia e controlli, cioè il vocabolario con cui si legge tutto il resto. Qui il laboratorio è l'inventario di una rete di macchine virtuali con Nmap e la lettura del traffico, e la funzione NIST è Identify. Il secondo gradino è la governance e corrisponde alla ISO/IEC 27001 Foundation, anch'essa in preparazione: porta dal singolo controllo tecnico al sistema di gestione, le clausole e l'Annex A, e si esercita compilando il questionario NIST CSF sul proprio ambiente. La funzione è Govern. Il terzo gradino è la visione d'insieme e corrisponde al CISSP, che il proprietario studia e il cui vincolo di esperienza resta il punto aperto: tiene insieme architettura, rischio e operazioni, e si esercita progettando i controlli delle funzioni Protect e Detect sul laboratorio. Le certificazioni manageriali e di rischio, CISM, CRISC, CIPM, che il proprietario ha messo da parte per i requisiti di esperienza, restano fuori dal percorso tecnico e dentro quello di governance quando l'esperienza maturerà.

A valle di ogni gradino sta un esercizio di laboratorio che produce un rapporto nel formato del pacchetto: l'inventario per Identify, una scansione Greenbone letta in priorità per la gestione delle vulnerabilità, l'hardening con HardeningKitty prima e dopo per Protect, un evento provocato apposta e letto con Sysmon e Hayabusa per Detect, la raccolta di artefatti con Velociraptor per Respond. Gli esercizi girano solo dentro la rete isolata del laboratorio, mai su un sistema di produzione.

## Che cosa manca e va procurato

Il corpus di studio è forte su fondamenti, reti, sistemi operativi, crittografia, cloud, web, governance e certificazioni, e più debole su quattro cose che il filone dovrà coprire con materiale nuovo: DORA, che non compare nel corpus e che per un'organizzazione che tratta dati finanziari è un obbligo accanto a NIS2; i processi di SOC e di risposta agli incidenti come runbook e non come cheatsheet; DevSecOps, container e Kubernetes, assenti dal corpus e rilevanti perché il template produce codice e usa Docker; e la gestione delle vulnerabilità come processo continuo e non come singola scansione. Queste quattro lacune sono il materiale da cercare nel prossimo passaggio di studio, e vanno registrate come fonti quando trovate.

## Rapporto con gli altri filoni e pacchetti

Questo percorso non vive da solo. La funzione Detect si appoggia al monitoraggio già progettato in `windows-status` scheda 17 e nel filone `linux-observability`, che raccoglie metriche e log tecnici: il filone cybersecurity vi aggiunge la lettura di sicurezza, non un secondo sistema di raccolta. La funzione Recover si appoggia ai pacchetti di continuità operativa. Il laboratorio è lo stesso ambiente di macchine virtuali del filone `linux-observability`, perché una macchina Linux amministrata serve a entrambi gli studi. Tenerli collegati è ciò che impedisce al template di avere tre sistemi che fanno la stessa raccolta per tre ragioni diverse.
