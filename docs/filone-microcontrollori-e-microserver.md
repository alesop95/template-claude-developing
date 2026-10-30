# Firmware, microserver e strumenti didattici nel browser

Mandato del29/10/2026 dal progetto home-lab: conservare e studiare strumenti accessibili dal browser per piccoli nodi di rete e un assistente a basso consumo. Settori di destinazione: Macchine e continuità operativa e IoT/firmware quando il catalogo avrà un trigger verificato. Oggi è un filone, senza nuovo pacchetto né installazioni. Il progetto d’origine conserva hardware, VLAN e roadmap nella propria documentazione; qui vive la parte riutilizzabile.

## Le fonti segnalate e quelle confrontate

| Fonte sorvegliata | Contenuto letto il29/10/2026 | Stato e costo da chiarire |
|---|---|---|
| `web:https://learn-esp32.vercel.app/` | HTML con venti lezioni, Wi-Fi ed esempio HTTP, codice e interfaccia JavaScript | candidato didattico; simulazione interattiva non collaudata, repository e licenza non accertati |
| `web:https://learn-arduino-red.vercel.app/` | HTML con sedici lezioni Uno, sensori, seriale e attuatori | candidato didattico; URL canonica senza query pubblicitaria; licenza e portabilità non accertate |
| `web:https://docs.wokwi.com/` | documentazione primaria di simulazione MCU con Arduino/ESP32/STM32/Pico e rete simulata | uso personale gratuito dichiarato, funzioni a pagamento distinte; condizioni di condivisione e progetto da valutare prima dell’uso |
| `web:https://www.falstad.com/circuit/` | pagina primaria del simulatore animato di circuiti, esempi e opzione offline | utile per tensioni e correnti; non è un emulatore di host Linux; condizioni e pacchetto offline da verificare prima dell’adozione |

Sono state lette pagine primarie, senza creare account, caricare credenziali o dati domestici, eseguire simulazioni interattive o misurare hardware. Il browser riceve codice del sito remoto: gli esercizi usano dati fittizi. La gratuità di accesso non attribuisce una licenza open source al sito. Prima di catalogare servono condizioni, destinazione dei progetti caricati, limiti gratuiti, ripetibilità e rimozione.

## La distinzione che il template deve conservare

Un microcontrollore serve firmware e piccoli endpoint; un agente completo con runtime, dipendenze, memoria persistente e client VPN richiede un host compatibile. Un modello remoto sposta l’inferenza, non elimina il runtime. Non assegnare una MCU a un progetto Linux perché entrambi espongono HTTP, e non contare una scheda citata in uno studio come acquistata. L’energia della MCU in sonno non è quella di un servizio sempre raggiungibile: confrontare lo stesso compito, disponibilità ed energia alla presa dell’intero nodo.

Una preferenza Wi-Fi si traduce in SSID associati alle VLAN per ruolo, con permessi espliciti, non in una zona unica per tutti i dispositivi radio. La simulazione del firmware non prova isolamento del Wi-Fi, regole del firewall, radio reale o consumi. Nessun cavo è vietato dal fatto che il nodo sia piccolo; affidabilità e costo energetico vanno misurati.

## Prova pilota prima del catalogo

Scegliere un esercizio minimo, salvare codice/configurazione in repository e riprodurlo da una sessione pulita del browser. Registrare quali funzioni richiedono account e dove finisce il codice. Ripetere sull’hardware scelto e separare le misure elettriche dal simulatore. Per la rete il passo discriminante è un collegamento vietato realmente rifiutato mentre il servizio autorizzato funziona. Per l’host agente verificare riavvio e recupero dello stato oltre al solo avvio del processo.

Il trigger futuro è un progetto con firmware o sensori da prototipare senza hardware, oppure una valutazione di microserver con runtime dichiarato. Oggi le quattro domande del catalogo restano incomplete su licenza, dati e collaudo: nessuna voce viene proposta automaticamente ai progetti e nessun MCP viene collegato. La chiusura potrà essere un pacchetto, una semplice scheda di strumenti esterni o archiviazione motivata. Le fonti entrano nel registro ordinario e si ricontrollano come gli altri candidati.
