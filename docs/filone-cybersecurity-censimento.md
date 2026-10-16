# Filone cybersecurity: censimento degli strumenti

> Allegato di `docs/filone-cybersecurity.md`, che contiene mandato, perimetro, vincoli e scelte. Qui stanno le tabelle per famiglia. Censimento del 2026-10-16 in due passaggi delegati a subagent e riletti: licenze lette dai file di licenza e dall'API di GitHub, date dell'ultimo rilascio dalla stessa API, telemetria e modalità offline dalle pagine di documentazione ufficiali lette attraverso uno strumento che le riassume. Nessuno strumento è stato installato o eseguito. «Da verificare» indica un dato non letto alla fonte primaria; «non dichiarato» indica che la pagina letta non ne parla, non che la cosa manchi.

## 1. Scanner di vulnerabilità

| Strumento | Che cosa fa | Licenza | Ultimo rilascio | Windows nativo | Dati che escono dalla macchina |
|---|---|---|---|---|---|
| Greenbone Community Edition (`openvas-scanner`, `gvmd`) | Scansione di rete con migliaia di test di vulnerabilità, report e storico; l'equivalente aperto più vicino a Nessus | GPL-2.0 lo scanner, AGPL-3.0 il gestore | 23.51.1 e 26.42.0, 2026-10-14/15 | No: container su Linux, oppure Docker o WSL2 | Feed comunitario dei test scaricato da Greenbone; bersagli e risultati locali |
| Nuclei | Verifiche a modelli YAML su servizi web, di rete, DNS e configurazioni | MIT, anche i modelli | 3.11.1, 2026-08-08; modelli 10.5.0, 2026-10-05 | Sì | Vedi la sezione 6 |
| Nmap con script NSE | Inventario di host, servizi, versioni e sistema operativo | Nmap Public Source License, non OSI | 7.992, tag del 2026-10-15 | Sì | Nessuno di per sé |
| `nmap-vulners` | Associa le versioni rilevate alle CVE note | Licenza di Nmap, non OSI | 2.0.2, 2026-08-20 | Dove gira Nmap | Invia a `vulners.com` servizi e versioni rilevati |
| Vuls | Pacchetti vulnerabili su host Linux e BSD via SSH, con banche dati CVE locali | GPL-3.0 | 0.42.0, 2026-10-15 | Lo scanner gira su Linux | Download delle banche dati CVE |
| OpenSCAP con ComplianceAsCode | Conformità di un host Linux a profili CIS e STIG | LGPL-2.1 il motore, BSD-3-Clause i profili | 1.4.5, 2026-10-13; profili 0.1.82 | No | Nessuna telemetria nota |
| Lynis | Audit di hardening di un host Unix | GPL-3.0 | 3.1.7, 2026-06-25 | No | Controllo di versione verso il sito del progetto |
| Trivy | Vulnerabilità, segreti e configurazioni in immagini, filesystem, repository e infrastruttura come codice | Apache-2.0 | 0.76.0, 2026-10-14 | Sì | Vedi la sezione 6 |
| Grype, con Syft | Vulnerabilità a partire da una distinta dei componenti | Apache-2.0 | 0.120.1, 2026-10-06 | Sì | Vedi la sezione 6 |
| OSV-Scanner | Dipendenze vulnerabili sulla banca dati OSV | Apache-2.0 | 2.7.0, 2026-10-12 | Sì | Vedi la sezione 6 |
| OWASP ZAP | Proxy e scanner di applicazioni web | Apache-2.0 | 2.17.0, 2025-12-15 | Sì | Vedi la sezione 6 |
| Nikto | Controllo di server web su casi noti | GPL-3.0 il codice, banca dati con licenza propria | 2.6.1, 2026-07-31 | Con Perl | Nessuna telemetria nota |

Greenbone presenta i propri container come strumento di prova, con un minimo di 2 core, 4 GB di RAM e 20 GB di disco, e il feed comunitario è un sottoinsieme di quello commerciale; il forum segnala ritardi del feed da luglio 2026, quindi si guarda la data dell'ultimo feed sincronizzato prima di fidarsi di un risultato. Il file `compose.yaml` si prende dalla documentazione ufficiale, perché il repository dei container non risponde con il nome citato. ZAP non ha rilasci stabili da dieci mesi.

## 2. Monitoraggio di sicurezza e log

| Strumento | Che cosa fa | Licenza | Ultimo rilascio | Windows nativo | Dati che escono dalla macchina |
|---|---|---|---|---|---|
| Wazuh | SIEM con agente: log, integrità dei file, vulnerabilità, conformità | GPL-2.0 con eccezione OpenSSL | 4.14.9, 2026-10-15 | Agente sì, server su Linux o container (da verificare) | Nessuno verso terzi se autogestito; feed vulnerabilità da verificare |
| Security Onion | Distribuzione Linux per monitoraggio di rete e caccia | Elastic License 2.0, non OSI | 3.3.0, 2026-09-11 | No, macchina dedicata | Aggiornamenti e regole dal progetto |
| Zeek | Analisi del traffico in log strutturati | BSD-3-Clause | 9.0.0, 2026-08-21 | No (da verificare) | Nessuno |
| Suricata | Rilevamento di intrusioni di rete a regole | GPL-2.0 | 8.0.7, 2026-09-15 | Installer MSI (da verificare) | Download delle regole |
| Sigma | Formato aperto di regole di rilevamento, indipendente dal SIEM | Regole sotto Detection Rule License 1.1, non OSI | r2026-07-01 | File di testo | Nessuno |
| Graylog Open | Raccolta e ricerca centralizzata di log | SSPL, non OSI | 7.2.0, data da verificare | Non supportato ufficialmente | Da verificare |
| Elasticsearch | Motore di ricerca alla base di molti SIEM | A scelta AGPL-3.0, SSPL o Elastic License 2.0; x-pack solo ELv2 | 9.5.5, 2026-10-06 | Sì | Telemetria da verificare |
| Velociraptor | Visibilità e monitoraggio continuo degli endpoint con query VQL | AGPL-3.0 | 0.77.3, 2026-10-05 | Sì (da verificare) | Locale in modalità autonoma (da verificare) |

Per poche macchine Windows si parte dalla telemetria locale, Sysmon con Hayabusa, e si aggiunge Wazuh come SIEM autogestito quando serve una vista centrale: ha l'agente per Windows e una licenza chiara. Suricata e Zeek servono solo dove esiste un punto da cui osservare il traffico. Il monitoraggio delle metriche e dei log tecnici già progettato in `windows-status` (scheda 17) e nel filone `linux-observability` è la base su cui questa famiglia si appoggia, non un doppione.

## 3. Risposta agli incidenti e analisi forense di una macchina propria

| Strumento | Che cosa fa | Licenza | Ultimo rilascio | Windows nativo | Dati che escono dalla macchina |
|---|---|---|---|---|---|
| Hayabusa | Linee temporali e rilevamento sui log eventi di Windows, con regole Sigma | AGPL-3.0 | 4.2.0, 2026-10-13 | Sì | Nessuno |
| Chainsaw | Ricerca rapida e rilevamento Sigma sui log eventi di Windows | GPL-3.0 | 2.17.1, 2026-10-14 | Sì | Nessuno |
| Velociraptor | Raccolta di artefatti e risposta agli incidenti | AGPL-3.0 | 0.77.3, 2026-10-05 | Sì | Nessuno verso terzi (da verificare) |
| Plaso | Linea temporale unificata dagli artefatti di una macchina | Apache-2.0 | 20260720 | Pacchetto Windows (da verificare) | Nessuno |
| Autopsy, su The Sleuth Kit | Analisi di immagini disco con interfaccia grafica | Apache-2.0 Autopsy; Sleuth Kit da verificare | 4.23.1, 2026-05-07; Sleuth Kit 4.15.0 | Sì | Alcuni moduli opzionali contattano servizi esterni (da verificare) |
| Volatility 3 | Analisi di dump di memoria | Licenza propria con copyleft sulle aggiunte, non OSI | 2.28.2, 2026-09-17 | Sì, Python | Nessuno |
| YARA | Riconoscimento di file e memoria tramite regole | BSD-3-Clause | 4.5.8, 2026-07-28 | Sì | Nessuno |
| KapeFiles | Definizioni di raccolta per KAPE, che invece non è open source | MIT | nessun rilascio, push del 2026-10-12 | Dipende da KAPE | Nessuno |

Il primo strumento per una macchina Windows propria è Hayabusa, con Chainsaw come controllo incrociato: binari singoli, nessuna dipendenza, nessun dato in uscita. Per un'immagine disco o un dump di memoria si passa ad Autopsy e Volatility 3, la cui licenza va letta prima di integrarlo in uno strumento che si distribuisce.

## 4. Basi di conoscenza per dare priorità ai risultati

| Fonte | Che cosa dà | Licenza | Aggiornamento | Uso |
|---|---|---|---|---|
| CISA KEV | Vulnerabilità sfruttate attivamente, in CSV e JSON | CC0 1.0, senza uso del logo | Push del 2026-10-15 | Primo filtro: una CVE in KEV si corregge prima |
| EPSS di FIRST | Probabilità di sfruttamento a 30 giorni per CVE | Termini da verificare | Giornaliero | Secondo filtro |
| NVD | CVE con punteggi CVSS e CPE, via API | Termini e limiti dell'API da verificare | Continuo | Gravità; le interrogazioni rivelano le CVE cercate |
| OSV | Vulnerabilità per ecosistema, con dump completo scaricabile | Per fonte: CC0, CC-BY, CC-BY-SA, BSD, MIT, Apache | Continuo | Dipendenze del software; il dump evita le interrogazioni puntuali |
| MITRE ATT&CK | Tattiche e tecniche, in STIX | Licenza MITRE gratuita con attribuzione, non OSI | 20.0, 2026-10-13 | Etichettare un rilevamento, non ordinarlo |
| MITRE D3FEND | Grafo delle contromisure difensive | Termini da verificare | Da verificare | Collegare una debolezza alla contromisura |
| MISP | Condivisione di indicatori di compromissione | AGPL-3.0 | 2.5.50, 2026-10-10 | Solo se si scambiano indicatori con altri |
| OpenCTI | Piattaforma di intelligence sulle minacce | Community Apache-2.0, Enterprise commerciale | 2026-10-16 | Come MISP: eccessiva per una sola organizzazione |

La sequenza minima per ordinare i risultati di una scansione è KEV, poi EPSS, poi CVSS da NVD: tre file scaricabili e confrontabili in locale, senza piattaforme da gestire.

## 5. Hardening e audit di Windows

| Strumento | Che cosa fa | Licenza | Ultimo rilascio | Dati che escono dalla macchina |
|---|---|---|---|---|
| HardeningKitty | Verifica e applica impostazioni di hardening secondo CIS, Microsoft e BSI, in PowerShell | MIT | 0.9.4, 2026-07-21 | Nessuno (da verificare) |
| Microsoft Security Compliance Toolkit | Baseline GPO ufficiali, Policy Analyzer, LGPO | Gratuito, non open source | Baseline per Windows 11 26H2 nella pagina del 2026-10-08 | Nessuno (da verificare) |
| Sysmon | Registra processi, rete, registro e DNS nel registro eventi | Proprietario Microsoft, gratuito | Pagina del 2026-09-10 | Nessuno: scrive nel registro eventi locale |
| `sysmon-modular` | Configurazione di Sysmon modulare, mappata su ATT&CK | MIT | 2026-10-14 | Nessuno |
| Configurazione Sysmon di SwiftOnSecurity | Configurazione di Sysmon più citata | Nessuna licenza individuata | Ferma al 2024-07-03 | Nessuno |
| Windows LAPS | Rotazione della password dell'amministratore locale | Integrato in Windows | Integrato da Windows 11 23H2 | Con Entra ID la password va al servizio Microsoft |
| PingCastle | Valutazione di sicurezza di Active Directory | Non-Profit OSL 3.0 nel repository; limiti per uso commerciale da verificare sulla pagina Netwrix | 4.0.0.31, 2026-10-13 | Controllo di aggiornamento da verificare |
| Purple Knight | Valutazione di AD, Entra ID e Okta | Gratuito, non open source | Non applicabile | Da verificare |
| CIS-CAT Lite | Verifica contro i CIS Benchmark | Gratuito dietro registrazione, non open source | Non applicabile | La registrazione raccoglie nome ed email |

Per una macchina sola si parte da HardeningKitty in modalità di sola verifica, confrontata con le baseline del Security Compliance Toolkit, e da Sysmon con `sysmon-modular` per la telemetria. Su una macchina aziendale vale prima di tutto il paletto 4 di `windows-status`: nessuna modifica a Defender, Windows Update o telemetria senza ordine esplicito, quindi l'hardening si misura prima di applicarlo e si applica una categoria alla volta.

## 6. Telemetria e modalità offline di cinque scanner

| Strumento | Telemetria | Come si spegne | Offline |
|---|---|---|---|
| Nuclei | Non dichiarata nelle pagine lette; il caricamento dei risultati sul cloud del produttore è opzionale e richiede una chiave | `-duc` spegne il controllo degli aggiornamenti; `DISABLE_NUCLEI_TEMPLATES_PUBLIC_DOWNLOAD` il download pubblico dei modelli | Nessuna procedura completa; cartella di modelli propria con `-ud` |
| Trivy | Sì, anonima e dichiarata, verso `check.trivy.dev`; attiva per default è un'inferenza | `--disable-telemetry` | Sì, documentata: banche dati scaricate con `--download-db-only` o da un registry interno, `--offline-scan` |
| Grype | Non dichiarata; controllo di nuova versione attivo per default | `GRYPE_CHECK_FOR_APP_UPDATE=false`, `GRYPE_DB_AUTO_UPDATE=false` | Banca dati ospitata in proprio puntando `db.update-url`; oltre 120 ore la banca dati vecchia fa fallire la scansione |
| OSV-Scanner | Non dichiarata; senza offline invia a `osv.dev` nomi e versioni dei pacchetti | `--offline` | Sì, documentata: `--download-offline-databases`, poi `--offline`; cartella in `OSV_SCANNER_LOCAL_DB_CACHE_DIRECTORY` |
| OWASP ZAP | Sì, componente Call Home: componenti in uso e statistiche interne, dichiarati senza dati dei siti scansionati | `-notel`, oppure `-silent`, o le opzioni Call Home | Gli aggiornamenti passano da Call Home anche con la telemetria spenta |

Per le dipendenze di un progetto si parte da OSV-Scanner offline, l'unico dei cinque la cui documentazione dichiara di non inviare dati del progetto con una procedura completa; Trivy è la seconda scelta, con telemetria spegnibile e procedura air-gap documentata.
