# Piano di potenziamento del template, mandato del 12 novembre 2026

> Documento di mandato dei filoni aperti il 2026-11-12, raggiunto da `docs/FILONI.md`. Mette in ordine tutto ciò che il proprietario ha consegnato il 12/11 con «per il goat.txt» e con i file che quel testo richiama: `POTENZIAMENTI GOAT.txt` e `handoff-nix.md` nella cartella dei download di Telegram, gli appunti sul DNS filtrante, sette schermate di Screenpresso (457-463) e nove immagini di Telegram (335-343). Il mandato dice che ogni voce va sviluppata nel template e non soltanto studiata, che ogni fonte va tracciata, spiegata e sorvegliata a ogni ripresa, e che nessuna va persa.

## Che cosa è misurato e che cosa no

Misurato il 12/11 sull'albero di `c2d2aa5`. Per ogni fonte del mandato ho cercato il suo nome con `git grep -i -F` su tutti i file tracciati e nel registro `.claude/templates/fonti-a-monte.json`: la colonna «Stato» delle tabelle viene da lì. Il carico di istruzioni, da `misura-istruzioni.py`: progetto 85.686 caratteri su una soglia di 100.000, di cui 69.430 di regole sempre attive; con la parte utente 93.581. Il margine è quindi di 14.314 caratteri, e le regole sono cresciute di 12.317 in trenta giorni.

Il 12/11 ho letto a monte, con l'interfaccia di GitHub, 46 repository del mandato: descrizione, licenza, stato, data dell'ultima modifica e l'inizio del README. È una lettura di ciò che la fonte dichiara di sé: nessuno strumento è stato installato o provato, e le cifre che i README riportano sul proprio rendimento restano affermazioni della fonte. Le letture grezze stanno nel livello privato del template, non in questo documento. Ciò che le tabelle dicono sull'uso atteso viene invece dalle parole del proprietario.

Restano nomi che non conosco e che non riempio per ipotesi: Jev, TypeSafe, la Decision API, DeepSeek Harness, Tailcat, l'opzione del consigliere della schermata 457. Per ciascuno il primo passo è la lettura.

## Che cosa la lettura alla fonte ha corretto

Sette cose scritte nel mandato non corrispondono a ciò che la fonte dichiara, e cambiano la destinazione della voce. `anthropics/oss-scanner` non è uno scanner da lanciare sul proprio codice: è un servizio a cui un progetto open source si iscrive aprendo una richiesta di unione, quindi serve solo a un progetto pubblico che voglia iscriversi. `cbrock84/headcount` il 12/11 risponde 404, repository e utente: resta una traduzione di terzi, e la voce si studia dalla schermata 461 finché l'originale non ricompare. Bend 2 si presenta come un linguaggio che verifica con prove ciò che un agente ha scritto, oltre che come linguaggio parallelo. `aayushch/laya` è un centro di notifiche locale che aggrega posta, chat e ticket con un modello locale, non un protocollo. `citrolabs/ego-lite` è un browser per agenti che condivide la sessione già autenticata, e `ayghri/i-have-adhd` è una skill sullo stile della risposta: nessuno dei due riguarda la scrittura non riconoscibile, e passano rispettivamente agli strumenti degli agenti e ai comandi di stile. `elder-plinius/cl4r1t4s` è una raccolta di prompt di sistema estratti da prodotti altrui, sotto AGPL-3.0: si legge per studio e non se ne copia testo nel template. Il paper CROW e llm-wiki-v2 sono la stessa cosa, `crow-hq/llm-wiki-v2`, anch'esso AGPL-3.0.

Tre repository hanno cambiato casa e nel registro stanno con il nome nuovo: `ai-job-search-dev/ai-job-search`, `cheaper-inference/OmniRoute`, `anomalyco/opencode`. Le licenze da guardare prima di adottare: AGPL-3.0 per `s60sc/ESP32_AdBlocker`, `crow-hq/llm-wiki-v2` e `elder-plinius/cl4r1t4s`, GPL-3.0 per AdGuard Home e paperless-ngx, e una licenza che GitHub non riconosce per Stirling PDF, llm_wiki, open-sesame, Remotion e Pi-hole, da leggere nel file.

## I vincoli che valgono per ogni onda

Il primo è il carico. Con 14.314 caratteri di margine nessuna feature di questo piano entra in `.claude/rules/` né nel `CLAUDE.md`: ogni capacità nuova è una skill con il suo `RIFERIMENTO.md`, un pacchetto del catalogo o un filone in `docs/`, che non costano niente a una sessione che non li apre. Dove una feature chiede davvero una riga sempre attiva, la riga si paga togliendone altrettanto altrove, e la misura prima e dopo si scrive nel commit.

Il secondo è il percorso di ingresso, che esiste già e non si aggira: una fonte nuova nasce come candidato in un filone, risponde alle quattro domande di `docs/FILONI.md` (che cosa fa, a quale progetto serve, che cosa costa, come si toglie) con la fonte letta, e solo allora diventa una riga di `.claude/templates/PACKAGES.md` con un trigger che il gate sa verificare. Si chiude in uno di tre modi: pacchetto, osservazione, archiviata con la ragione.

Il terzo è la parità. Ogni comando, skill o strumento nuovo funziona da Claude Code e da Codex: dove uno dei due lo fa nativamente si usa il nativo, e per l'altro si scrive l'adattatore. Il quarto è il costo: il lavoro meccanico di lettura delle fonti va a subagent economici o al modello locale, il giudizio sulle quattro domande resta nella conversazione principale. Il quinto è la suite Craft: per ogni compito che un programma della suite sa fare in locale si propone quello prima di una libreria o di un servizio.

## Le onde

L'ordine segue le dipendenze: ciò su cui il resto si appoggia viene prima, i filoni verticali che non dipendono l'uno dall'altro vengono dopo e si possono fare in qualunque ordine il proprietario preferisca.

### Onda 0. Censimento: nessuna fonte persa

Fatta il 12/11. Questo documento è tracciato e ogni fonte che nomina è nel registro delle fonti a monte con ruolo, motivo e data di verifica, perché il censimento legge da sé i documenti del template. Le pagine che non sono repository portano il prefisso `web:`, e quelle che cambiano a ogni visita si rivedono a mano entro una scadenza. I post di LinkedIn e di Telegram che il proprietario ha incollato non sono fonti interrogabili: valgono le fonti primarie a cui rimandano, che sono nel registro. Il thread «Drop your best Claude skills in here» era già nel registro e in `docs/fonti-di-scouting.md`.

Esito atteso: il registro contiene tutte le fonti del mandato, ognuna con ruolo, motivo e data di verifica; `FILONI.md` le raggiunge tutte; la raccolta a ogni ripresa le interroga.

### Onda 1. Fondamenta trasversali

| Voce | Dal mandato | Stato | Che cosa si costruisce |
|---|---|---|---|
| 1.1 Carico di istruzioni | Avviso di 178.500 caratteri in un progetto istanziato; soglia di 100.000 da rispettare a ogni ripresa e istanziazione | Il template sta a 85.686; il progetto dell'avviso va rimisurato oggi, l'episodio è precedente allo spostamento delle norme nelle skill | Verifica alla documentazione di Claude Code delle regole legate a percorsi; misura del carico dentro la passata per ogni progetto, con il verdetto nella ricevuta; procedura per rientrare sotto soglia |
| 1.2 Comandi di ragionamento, con parità | I sedici comandi dell'elenco «16 Claude Commands Worth Stealing» di GenAI.works: godmode, ghost, artifacts, secondorder, redteam, assumptions, steelman, premortem, ooda, devil, matrix, brief, roast, silent, lockin, steal | Assenti; `steelman` compare solo in `academic-researcher` | Prima si legge che cosa Claude Code e Codex offrono già di nativo; il resto diventa un pacchetto di comandi catalogati per filone (analisi critica, decisione, stile di risposta, creatività), con l'adattatore per l'altro client e senza toccare le regole |
| 1.3 Skill native prima di quelle scritte | «Se una parte si realizza già nativamente si usa» | Da misurare | Lettura delle documentazioni di Anthropic e OpenAI sulle skill, confronto con le 18 skill del template e segnalazione dei doppioni |
| 1.4 Scelta del modello per compito | Subagent economici in automatico; non tutto con il modello più capace; schermata 457 (sessione principale su un modello medio, consigliere più capace a chiamata, sciame economico) | `instradamento-modelli` esiste ed è attivo su questa macchina | Verifica dell'opzione del consigliere alla documentazione; se esiste, profilo «lead medio, consigliere a chiamata» come scelta dell'instradamento; taratura su un piano Pro |
| 1.5 Modello locale come regola di decisione | Rilevare il modello disponibile sulla macchina della sessione e usarlo per i compiti a cui basta; servizio Ollama della rete locale | `llm-local` e `docs/offload-modello-locale.md` esistono | Rilevamento all'apertura (servizio raggiungibile, modelli presenti), tabella compito-modello misurata su un lotto piccolo, verdetto nella ripresa. L'indirizzo del servizio resta in un file locale e non in un file tracciato |
| 1.6 Instradamento verso serbatoi gratuiti | `https://github.com/cheaper-inference/OmniRoute`; ccusage | ccusage presente; OmniRoute assente | Quattro domande su OmniRoute, con attenzione a quali dati escono dalla macchina |
| 1.7 Ripresa dopo `/clear` | Riprendere da sé una sessione nuova dopo il `/clear` nativo | `riprendi` esiste, l'aggancio a `/clear` no | Lettura della documentazione degli hook di avvio per distinguere l'apertura dalla pulizia; se la distinzione c'è, la ripresa breve parte da sola |
| 1.8 `sync-context` automatico | Riancoraggio delle schede da sé quando si rileva una deriva | La skill esiste, si invoca a mano | Misura della deriva nell'hook di apertura e proposta della sanatoria nello stesso giro |
| 1.9 Simultaneità fra passata e sessione di progetto | «Siamo sicuri che ogni progetto capisce se è bloccato dal template, alberi paralleli compresi, così da non lanciare subito `chiudi`?» | Non verificato: non ho letto le guardie di `allinea-tutti` e di `chiudi` con questa domanda | Lettura del codice, prova con due sessioni finte, e se manca un segnale visibile dal progetto lo si aggiunge (un file di passata in corso che `chiudi` legge) |
| 1.10 Miniera alla ripresa | Controllare a ogni ripresa se la miniera ha qualcosa di nuovo per i filoni | Il thread è sorvegliato per impronta | Che la novità arrivi come elenco di candidati e non come «pagina cambiata» |
| 1.11 Configurazione di Claude su Windows e Linux | web:https://code.claude.com/docs/en/debug-your-config | Assente | Filone «setup del client», che alimenta la mappa e la guida d'uso |
| 1.12 Guida grafica completa | Un documento grafico che accompagna la guida d'uso e spiega ogni cosa che il template fa, compresi pulizia delle sessioni, wipe e idempotenza degli adattatori Codex | Esistono `docs/feature-map.html`, `docs/guida-sessione.html`, `docs/project-flow.html` | Si rifà per ultimo, quando le onde hanno cambiato ciò che descrive, e si aggiorna a ogni onda per la parte toccata |

Avanzamento dell'onda 1 al 2026-11-12. Fatte: la 1.9, perché la risposta alla domanda era no e ora la passata lascia nella cartella di git del progetto l'elenco dei file consegnati, che ferma `chiudi` se finiscono nel suo commit; la 1.7, con la testa del file di ripresa iniettata dopo `/clear` e dopo una compattazione; la 1.2, con il pacchetto `comandi-ragionamento`; la 1.5, con `llm-local/tools/rileva-endpoint.py` e una prima misura su un servizio di rete, che ha fatto correggere il banco di correttezza; la 1.4 come documentazione del consigliere nel README di `instradamento-modelli`, senza misura del costo; la 1.11 come procedura in `docs/filone-setup-del-client.md`, non provata. Già esistenti, verificate leggendo il codice: la 1.1, perché la misura del carico esclude le regole con `paths:` e la passata la esegue su ogni progetto, e la 1.8, perché l'hook di apertura chiede già `sync-context`. Da fare: 1.3, 1.6, 1.10 e 1.12.

### Onda 2. Il cervello degli agenti: memoria di progetto come vault

È la parte che il proprietario indica come principale. Il template ha già `memoria-di-progetto`, `knowledge-wiki` (che cita il wiki di Karpathy), `rea`, `book-to-skill`, `codebase-learning` con graphify, e la proposta del motore di lettura ancorata. Il mandato chiede di potenziarla senza togliere niente.

| Fonte | Dal mandato | Stato | Destinazione |
|---|---|---|---|
| Metodo di Karpathy con Obsidian, più Jev | «Studiamolo insieme»: ogni memoria di progetto può diventare un vault | Karpathy citato in tre pacchetti; Jev sconosciuto a me e al proprietario | Studio alla fonte, poi disegno del vault di progetto |
| web:https://www.youtube.com/watch?v=t7IXUaRyUAY e web:https://www.youtube.com/watch?v=EP9zPS1jNwA | Da trascrivere in locale con la GPU e il progetto di trascrizione di questa macchina | Assenti | Trascrizione, poi lettura; insieme si verifica la catena video-testo (voce b dei potenziamenti: 403 di YouTube e deno) |
| `https://github.com/obra/superpowers` | Al centro: prima del prompt zero, per arrivare a un MVP; permette di impostare il carattere | Assente | Confronto con `init-project-system`, `micro-passi` e `matt-pocock-skills`: che cosa fa meglio, dove entra nel flusso di istanziazione |
| `https://github.com/Egonex-AI/Understand-Anything` | Con `rea`, perché produce grafi | Assente | Confronto con graphify e `codebase-learning` |
| `https://github.com/storytold/craft-anything` | Già dentro la suite Craft | Assente come fonte | Registrazione e legame con `rea` |
| `https://github.com/nashsu/llm_wiki`, `https://github.com/crow-hq/llm-wiki-v2` con il suo paper CROW, web:https://doi.org/10.5281/zenodo.22898752 | Filone libri e ricerca | `knowledge-wiki` esiste; queste fonti no | Confronto con `knowledge-wiki` |
| `https://github.com/tirth8205/code-review-graph` | Risparmio di token | Assente | Confronto con graphify sul costo per domanda |
| Vault Obsidian di base (voci e, f dei potenziamenti) | Vault con un insieme minimo di plugin deciso insieme, scelto all'istanziazione o all'allineamento; skill che tiene la documentazione poco frammentata | Un vault di riferimento esiste su questa macchina; nel template niente | Pacchetto «vault di progetto» e skill di organizzazione della documentazione |
| Hermes Agent, `https://github.com/NousResearch/hermes-agent`, con `handoff-nix.md` | «Hermes sotto con l'handoff», da mettere con il secondo cervello | Hermes citato nel catalogo; l'handoff sta già nel progetto del laboratorio, identico per SHA-256 al file dei download | Lezione astratta per il template: agente personale sempre acceso che legge la stessa memoria |
| Lezioni, in entrambe le direzioni | Potenziare il ciclo lezione di progetto, template, progetti | Esiste e oggi è a zero aperte | Analisi di ciò che il ciclo non cattura: lezioni mai scritte, lezioni di stack |

Esito atteso: un progetto può scegliere di avere la memoria come vault navigabile, più agenti leggono la stessa memoria invece di ricostruirla, e il risparmio si misura prima e dopo su un progetto reale.

### Onda 3. Orchestrazione di più agenti

Il proprietario la vuole a monte di ogni progetto, richiamabile per un progetto o per un compito. Il template ha `agenti-terminale`, la posta fra sessioni, `nimbalyst`, `agent-catalog`, `lavoro-a-lotti` e il filone degli strumenti agentici.

| Fonte | Dal mandato | Stato | Destinazione |
|---|---|---|---|
| `https://github.com/ruvnet/ruflo` | Far parlare più agenti | Assente | Quattro domande |
| `https://github.com/affaan-m/ECC` e il profilo `https://github.com/affaan-m` | «Da esplorare, spulciare, integrare» | Assente | Lettura per parti, che cosa il template non ha |
| headcount, di cbrock84 (schermata 461; il repository non risponde) | Agenti organizzati come reparti installabili | Assente | Confronto con `agent-catalog` |
| DeepSeek Harness | Il modello d'uso (attivazione su evento, riproduzione del guasto, correzione, richiesta di unione, lavoro in parallelo), ma con Claude e Codex | Assente | Studio del solo disegno; confronto con le routine e gli hook che i due client hanno già |
| Schema «Harness engineering» (schermata 459) | Contratto, contesto, stato, strumenti, permessi, prove | Assente | Griglia con cui rileggere il template: che cosa copre ogni casella e dove manca |
| Post sui modelli «System One»: Jev, la Decision API e CLM, `https://github.com/Contrastive-LM/CLM`, con la pagina web:https://contrastive-lm.notion.site | Studiare l'integrazione di protocolli nuovi | Assente | Osservazione: un modello che decide accanto a quello che ragiona; da leggere prima di dire se un client lo può usare |
| Ricerca strutturata (voce l dei potenziamenti) | Più agenti insieme al costo minimo, tarato su un piano Pro, con ciò che è stato scritto su Reddit e dev.to | Aperta | Documento di ricerca nel filone, poi attuazione |
| «Separare i lavori»: le nove immagini di Telegram | Otto lavori, otto specialisti: OpenHuman (agente personale e secondo cervello), MiroMind (ricerca a passi verificati), Google Stitch (interfacce), OpenCode con un modello Qwen locale (codice senza rete), n8n (flussi programmati e visibili), Qwen (progetti), NotebookLM (studio), Langflow, `https://github.com/langflow-ai/langflow` (agenti visuali) | n8n e NotebookLM presenti; gli altri assenti; di OpenHuman e MiroMind non ho trovato un repository certo | Tabella «quale strumento per quale lavoro» nel catalogo, con il modo gratuito dichiarato dalla fonte e verificato |
| `https://github.com/anomalyco/opencode` e `https://github.com/jesseduffield/lazygit` (voce v), `https://github.com/citrolabs/ego-lite`, `https://github.com/aayushch/laya` | Capire come integrarli | Assenti | Quattro domande |

### Onda 4. Filoni verticali

Sono indipendenti fra loro. Per ciascuno: lettura alla fonte, quattro domande, e dove passa una pipeline locale provata su un progetto reale del proprietario.

| Filone | Fonti e richieste | Stato | Progetto su cui provarlo |
|---|---|---|---|
| Diagrammi e reti | `https://github.com/agents365-ai/drawio-skill`; ricerca di strumenti simili e di quelli per la visualizzazione interattiva di un'infrastruttura di rete; timeline e grafici consultabili come artefatti locali | `timeline-progetto` esiste; il resto no | Il progetto di disegno di rete |
| Modellazione 3D e CAD | `https://github.com/wheresryan22/anatomy`, `https://github.com/el4cteo/blender-skills`, `https://github.com/earthtojake/text-to-cad`, Blender, il programma CAD della suite Craft | Assenti | I due progetti audio, per le casse |
| PDF e documenti | `https://github.com/Stirling-Tools/stirling-pdf` | Assente | Confronto con ciò che la suite Craft fa già |
| Fiscale | `https://github.com/paperless-ngx/paperless-ngx` | Assente | Vale la regola sui documenti personali: lo strumento si installa, i documenti non si leggono |
| Scrittura non riconoscibile come generata | `github:blader/humanizer` («funziona bene?»), `https://github.com/petergyang/no-ai-slop`; lo stile di risposta di `https://github.com/ayghri/i-have-adhd`; completezza della correzione di accenti e grammatica rispetto a un progetto che l'ha estesa | humanizer è già in `anti-slop`; gli altri no | Misura di humanizer su testi veri, con il costo di tenerlo sempre attivo |
| Web design e animazione | `https://github.com/pbakaus/impeccable`, Google Stitch, `https://github.com/remotion-dev/remotion` con il suo plugin, web:https://www.remotion.dev/docs/ai/claude-code-plugin | Assenti | Un sito del proprietario |
| Didattico | `https://github.com/tt-a1i/archify` | Assente | Con `studio-didattico` e `documentazione-didattica` |
| Sviluppo full-stack | La lista della schermata 458 (una quarantina di controlli prima del rilascio, da CI e prove fino a posta autenticata, limiti di spesa, ripristino provato, consenso ai cookie); il testo su CI e CD con le cinque insidie; `https://github.com/bendlang/bend`; il thread delle schermate 462 e 463 su produzione e sviluppo, dove la risposta più votata manda i log a una piattaforma di osservabilità che l'agente legge via MCP | `pipeline-app` e `separazione-ambienti` esistono | La lista diventa un controllo di `pipeline-app` che dice, voce per voce, presente, assente o non applicabile; la risposta del thread entra nel pacchetto di osservabilità |
| Python da senior | Ambiente virtuale separato, dipendenze bloccate, ruff, gli stessi controlli in locale e in CI | `stack-profiles/profiles/python.md` cita ruff | Estensione del profilo, sul modello del progetto del proprietario che lo fa già |
| Rust, Go e prestazioni | Skill da programmatore senior di Go e di Rust; il post di confronto come spunto | Assenti le skill | Ricerca delle skill esistenti prima di scriverne |
| Android | `https://github.com/HQarroum/docker-android/`, `https://github.com/ionic-team/capacitor`, l'impianto di un progetto del proprietario; emulatore utile solo con accelerazione, quindi su Linux | Assente | Pacchetto offerto al gate quando il progetto dichiara Android |
| Sicurezza e auto-verifica | `https://github.com/hassan-algo/open-sesame`, `https://github.com/anthropics/oss-scanner`, `https://github.com/usestrix/strix` | Filone aperto, queste fonti assenti | Solo sui propri sistemi; lo scanner anche sugli strumenti che il template adotta |
| Prompt efficaci | `https://github.com/elder-plinius/cl4r1t4s` | Assente | Lettura come materiale di studio su come sono scritti i prompt di sistema; si decide dopo che cosa se ne prende |
| Laboratorio di casa e riservatezza | `https://github.com/s60sc/ESP32_AdBlocker` con l'articolo web:https://ei.futuranet.it/2026/11/07/blocco-dns-su-esp32-c3-addio-pubblicita-senza-psram/ , `https://github.com/AdguardTeam/Adguardhome`, `https://github.com/pi-hole/pi-hole`, le liste di web:https://firebog.net/ , gli appunti sul DNS filtrante, Veeam per Windows, Tailcat (web:https://www.ilsoftware.it/focus/tailcat-collega-due-pc-ovunque-senza-vpn-account-porte-aperte/ ), due post sui modelli locali | `veeam-linux` esiste; il filone dei microcontrollori è aperto | Si propaga al progetto del laboratorio con la posta fra sessioni |
| Trading | `https://github.com/shiyu-coder/Kronos` e `https://github.com/Jakeschincariol/day-trader-skill`, più il ciclo di agenti che si riscrivono, dai due post incollati | Assente | Filone di osservazione. Le cifre dei post sono promozione e non una misura; qualunque prova resta su un conto simulato |
| Ricerca | web:https://core.ac.uk/ , web:https://scispace.com/it , web:https://www.connectedpapers.com/ , web:https://doaj.org/ , `https://github.com/lfnovo/open-notebook`, MiroMind | open-notebook citato nella mappa scientifica | In `academic-researcher` |
| SEO | `https://github.com/every-app/open-seo`, con la ricerca fatta in un progetto del proprietario | Assente | Quel progetto |
| Curriculum | `https://github.com/ai-job-search-dev/ai-job-search` | Assente | Proposta al solo progetto del curriculum |
| Voce | `https://github.com/kyutai-labs/pocket-tts` | Assente | Con `voicestudio` |
| Fonti di comunità | Esportazione delle chat di Telegram fra due date con filtri, sul modello di due progetti del proprietario; ricontrollo di Reddit e Discord | `community-sources` ha già `read-chat-export.py` | Estensione di `community-sources` |
| Varie | web:https://arxiv.org/abs/2603.21852v2 ; `https://github.com/Cranot/claude-code-guide` (già nel registro, da ricontrollare per ciò che è cambiato); la skill wayfinder di web:https://www.aihero.dev/skills-wayfinder ; `https://github.com/mattpocock/skills` (già nel registro); strumenti generici da un progetto di traduzione; gestione di un blog; le app da terminale per Linux | Miste | Una per una |

### Onda 5. I progetti come banco di prova tecnico

Il filone `docs/filone-stack-benchmark.md` è aperto dal 16/10 senza nessuna lezione estratta. Il mandato lo allarga: dai progetti che la passata già raggiunge, su `D:`, `E:` e nelle macchine virtuali, si ricavano quattro studi. Il primo sugli stack che funzionano, con l'adattatore di database in corso in un progetto come primo caso, da proporre accanto alle migliori soluzioni aperte. Il secondo sui modi di separare prova e produzione e sulle scelte di hosting. Il terzo sull'organizzazione delle cartelle per tipo di progetto, perché non si frammentino. Il quarto sul metodo di chi conduce benchmark e statistica, da un progetto che lo ha fatto.

La lettura di molti progetti per estrarre lo stesso dato è lavoro meccanico e va a subagent, uno per gruppo di progetti; l'astrazione resta qui. Una soluzione entra nel template come collaudata solo se nel progetto d'origine c'è la prova che funziona, e la scheda dice quale.

### Onda 6. Chiusura

Guida grafica completa, aggiornamento di `README.md` con `sync-readme`, misura finale del carico, una passata di allineamento e la verifica su tre progetti di tipo diverso che il gate proponga le cose nuove al momento giusto.

## Che cosa è già stato fatto il 12/11

Gli appunti sul DNS filtrante sono stati consegnati al livello privato del progetto del laboratorio, come chiesto. Il documento di consegna sull'agente personale era già in quel progetto dal 29/10, identico per SHA-256 a quello ricevuto: non c'era niente da copiare.

## Decisioni del proprietario del 12/11

La struttura a onde è confermata. La guida grafica segue l'identità del progetto: il design privato per i progetti privati, quello dell'organizzazione per i progetti dell'organizzazione, cioè la stessa regola con cui `craft-documento.py --stile auto` sceglie già il design dall'identità git. Il vault di base prende i plugin dei vault che esistono già sulla macchina del proprietario, da censire all'onda 2. I comandi di solo tono entrano nel pacchetto dei comandi come gli altri. L'ordine dei filoni dell'onda 4 non è stato fissato: si procede nell'ordine della tabella finché il proprietario non ne indica un altro.
