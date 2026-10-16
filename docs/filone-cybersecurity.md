# Filone: strumenti per l'assessment di sicurezza

> Aperto il 2026-10-16 su richiesta del proprietario, come filone dedicato agli strumenti open source per valutare la sicurezza dei propri sistemi. Stato: censita la famiglia degli scanner di vulnerabilità, due raccolte di studio lette in superficie, nessuno strumento provato, nessun pacchetto. Indice dei filoni in `docs/FILONI.md`.

## Il mandato e il suo perimetro

Il proprietario chiede una linea propria per gli strumenti di sicurezza informatica che si trovano open source, con un obiettivo dichiarato: poter fare da sé il *vulnerability assessment*[^1] e le verifiche di sicurezza delle proprie macchine e delle proprie reti, senza dipendere da prodotti commerciali come Nessus, e con scopi etici. Il perimetro è quindi l'assessment di sistemi propri o di sistemi su cui si ha un'autorizzazione scritta del proprietario, e ogni strumento del filone si valuta da questo punto di vista: che cosa permette di vedere di un sistema che si amministra, e con quale rischio per quel sistema.

Il template oggi ha strumenti di sicurezza sparsi in settori pensati per altro: la regola sui permessi e il sandbox, il pacchetto `anonymization` per i dati identificanti, la revisione di sicurezza del codice fra le capacità di revisione. Nessun settore è riconosciuto da un progetto il cui obiettivo sia l'assessment stesso, ed è quello che il filone deve costruire.

## Scanner di vulnerabilità: l'alternativa aperta a Nessus

Censimento del 2026-10-16, delegato a un subagent e riletto per intero: licenze lette dai file `LICENSE` o `COPYING` e dall'API pubblica di GitHub, date dell'ultimo rilascio dalla stessa API, nessun repository archiviato. Nessuno strumento è stato installato o eseguito. Le celle che dicono «da verificare» non sono state lette alla fonte primaria.

Il rapporto con Nessus è storico. Nell'ottobre 2005 Tenable chiuse la licenza di Nessus, e dall'ultima versione aperta nacque il fork che oggi si chiama OpenVAS ed è il motore di scansione dentro Greenbone; la fonte di questa ricostruzione è Wikipedia, non una fonte primaria.

| Strumento | Che cosa fa | Licenza | Ultimo rilascio | Windows nativo | Dati che escono dalla macchina |
|---|---|---|---|---|---|
| Greenbone Community Edition (`openvas-scanner`, `gvmd`) | Scansione di rete con migliaia di test di vulnerabilità, report e storico; è l'equivalente aperto più vicino a Nessus | GPL-2.0 lo scanner, AGPL-3.0 il gestore | 23.51.1 e 26.42.0, 2026-10-14/15 | No: container su Linux, oppure Docker o WSL2 su Windows, da provare | Scarica il feed comunitario dei test da Greenbone; bersagli e risultati restano locali |
| Nuclei | Scansione a modelli YAML di applicazioni web, servizi di rete, DNS e configurazioni, ripetibile e scriptabile | MIT, anche i modelli | 3.11.1, 2026-08-08; modelli 10.5.0, 2026-10-05 | Sì | Aggiorna i modelli da GitHub; l'invio al cloud del produttore è opzionale; telemetria anonima da verificare |
| Nmap con script NSE | Scoperta di host, servizi, versioni e sistema operativo; base di ogni assessment | Nmap Public Source License, non OSI | 7.992, tag del 2026-10-15 | Sì | Nessuno di per sé; gli script che interrogano servizi esterni vanno guardati uno per uno |
| `nmap-vulners` | Script NSE che associa le versioni rilevate alle CVE note | Stessa licenza di Nmap, non OSI | 2.0.2, 2026-08-20 | Dove gira Nmap | Invia a `vulners.com` servizi e versioni rilevati: da escludere su reti di terzi |
| Vuls | Controllo senza agente, via SSH, dei pacchetti vulnerabili su host Linux e BSD, con banche dati CVE locali | GPL-3.0 | 0.42.0, 2026-10-15 | Lo scanner gira su Linux | Scarica le banche dati CVE; i risultati restano locali |
| OpenSCAP con i profili ComplianceAsCode | Conformità di un host a profili di hardening come CIS e STIG | LGPL-2.1 il motore, BSD-3-Clause i profili | 1.4.5, 2026-10-13; profili 0.1.82, 2026-09-01 | No | Nessuna telemetria nota |
| Lynis | Audit di hardening di un host Unix, a script di shell | GPL-3.0 | 3.1.7, 2026-06-25 | No | Il controllo di versione contatta il sito del progetto |
| Trivy | Vulnerabilità, segreti e configurazioni errate in immagini container, filesystem, repository e infrastruttura come codice | Apache-2.0 | 0.76.0, 2026-10-14 | Sì | Scarica le banche dati da un registry pubblico; modalità offline da verificare |
| Grype, con Syft | Vulnerabilità di immagini e filesystem a partire da una distinta dei componenti | Apache-2.0 | 0.120.1, 2026-10-06 | Sì | Scarica la propria banca dati; controllo aggiornamenti da verificare |
| OSV-Scanner | Dipendenze vulnerabili in lockfile, distinte e immagini, sulla banca dati OSV | Apache-2.0 | 2.7.0, 2026-10-12 | Sì | Interroga `osv.dev` con nomi e versioni dei pacchetti, salvo modalità offline da verificare |
| OWASP ZAP | Proxy e scanner di applicazioni web, passivo e attivo, con modalità di automazione | Apache-2.0 | 2.17.0, 2025-12-15 | Sì | Aggiornamento dei componenti aggiuntivi; telemetria da verificare |
| Nikto | Controllo di server web su una banca dati di casi noti, rumoroso e datato nell'approccio | GPL-3.0 il codice, banca dati con licenza propria | 2.6.1, 2026-07-31 | Con Perl | Nessuna telemetria nota |

La lettura che ne deriva, da confermare con le prove, è che un assessment fatto in proprio ha bisogno di tre livelli e non di uno strumento. Nmap per sapere che cosa c'è sulla rete, sempre presente, sapendo che la sua licenza non è OSI e va bene per uso interno ma non per essere incorporata in un prodotto ridistribuito. Greenbone Community Edition per la scansione ampia con report e storico, accettando due limiti dichiarati dalla documentazione del produttore: i container sono presentati come strumento di prova e familiarizzazione, con un minimo di 2 core, 4 GB di RAM e 20 GB di disco, e il feed comunitario è un sottoinsieme di quello commerciale, con ritardi di aggiornamento segnalati sul forum da luglio 2026, quindi prima di fidarsi di un risultato si guarda la data dell'ultimo feed sincronizzato. Nuclei per le verifiche mirate e ripetibili, che si possono rilanciare dopo ogni correzione. Per gli host Linux amministrati si aggiungono Vuls e OpenSCAP, che guardano dall'interno con credenziali invece che dall'esterno, e per il software che si sviluppa Trivy o OSV-Scanner, che nel template hanno anche una seconda casa naturale nel settore dello sviluppo.

Restano da leggere alla fonte primaria la telemetria e le modalità offline di Nuclei, Trivy, Grype, OSV-Scanner e ZAP, e l'annuncio di rilascio di Nmap 7.992. Il repository `greenbone/community-containers` citato dalla documentazione non risponde con quel nome, quindi il file `compose.yaml` si prende dalla pagina della documentazione ufficiale e non da un percorso supposto.

## Le due raccolte di studio, lette il 2026-10-16

Lettura delle pagine dei due repository attraverso uno strumento di recupero che riassume; le cartelle interne non sono state aperte.

`s4ntrx/Cybersecurity-Threats-Guide` è una guida in sei categorie, cioè sicurezza di rete, applicazioni web, analisi del malware, ingegneria sociale, crittografia e risposta agli incidenti, con script Python di rilevamento e prevenzione per argomento. Licenza MIT, circa 216 stelle. Si dichiara da sé in fase iniziale: gli argomenti aggiunti a ottobre 2026 sono bozze con fonti da rivedere e gli script che toccano il sistema sono stati verificati leggendo il codice, non eseguendolo.

`CyberSaiyanIT/rhc2026-resources` raccoglie slide, codice e materiali dei circa ventisei interventi di RomHack Camp 2026, dal 2 al 4 ottobre, più un workshop con CTF[^2]. Nessuna licenza indicata sulla pagina, quindi il riuso del materiale non è definito.

Entrambe sono materiale di studio e non strumenti da installare. Alimentano il registro delle fonti di un progetto di assessment, con l'etichetta di ciò che se ne è letto davvero.

## Le famiglie ancora da censire

Il censimento degli scanner è la prima famiglia. Le successive, nello stesso formato e con lo stesso perimetro di assessment dei propri sistemi, sono la raccolta e l'analisi di log ed eventi di sicurezza su una rete propria, che si collega al filone `linux-observability` e al monitoraggio aperto del parco già documentato in `windows-status`; la risposta agli incidenti e l'analisi forense di una macchina propria; le basi di conoscenza strutturate sulle tecniche d'attacco, che servono a leggere un risultato e a dargli una priorità; e l'hardening delle macchine Windows, che su questa macchina tocca da vicino il lavoro di `windows-status`. Ogni famiglia si chiude con una candidata per uso, letta alla fonte primaria, con licenza, piattaforma e dati che escono dalla macchina.

## Vincoli che valgono fin da ora

Si scansionano soltanto sistemi propri o sistemi per cui si ha un'autorizzazione scritta di chi li possiede, e una rete aziendale non è propria anche quando ci si lavora ogni giorno: serve l'autorizzazione di chi la amministra. Una scansione attiva può rallentare o bloccare un servizio, quindi la prima corsa su un sistema reale si fa in una finestra concordata e con le opzioni meno invasive. Gli strumenti si installano in un ambiente separato, una macchina virtuale o un container, e non sulla macchina che ospita i repository di clienti; vale la stessa disciplina di `.claude/rules/security-permissions.md`, che su Windows nativo non ha sandbox e indica WSL2 o Docker per l'isolamento. I risultati di un assessment descrivono le debolezze di una macchina reale e sono quindi dati riservati: non entrano mai in un repository tracciato, e nei documenti versionati si usano i segnaposto del pacchetto `anonymization`. Uno strumento che invia a un servizio esterno ciò che ha rilevato, come `nmap-vulners`, si dichiara come tale e si esclude dove la riservatezza lo richiede.

## Destinazione nel catalogo

Il settore proposto è «Sicurezza informatica e assessment», riconosciuto dalla domanda se l'oggetto del progetto sia la sicurezza di sistemi che il progetto amministra o è autorizzato a verificare, cioè valutarla, misurarne i miglioramenti o ricostruirne un incidente, e non soltanto scrivere codice sicuro, che resta nel settore dello sviluppo. Il primo pacchetto candidato è un `assessment-vulnerabilita` con i tre livelli descritti sopra: una guida che ne raccoglie le decisioni, un file di parametri privato per i bersagli autorizzati, gli script di allestimento dei container con versioni fissate e impronte, e un modello di rapporto che separa ciò che lo strumento dichiara da ciò che è stato verificato a mano. Il settore si apre con quella prima voce, quando avrà superato le quattro domande di `docs/FILONI.md` con almeno una prova su una macchina di laboratorio, e non prima, perché un settore vuoto nel catalogo sarebbe una domanda del gate senza nessuna proposta dietro. Se il pacchetto porterà una regola sotto `.claude/rules/`, per esempio sull'autorizzazione e sulla riservatezza dei risultati, il suo peso in caratteri si misura e si dichiara nel catalogo prima del rilascio, per la guardia dei 100.000.

[^1]: *Vulnerability assessment*, valutazione sistematica delle debolezze note di un sistema, di solito con scanner automatici, che si distingue dal *penetration test* perché elenca le vulnerabilità invece di provare a sfruttarle.

[^2]: *CTF*, Capture The Flag, competizione di sicurezza informatica in cui si risolvono prove tecniche per recuperare una stringa segreta.
