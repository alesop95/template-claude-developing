# Hook SessionStart (variante Windows): rende automatica la verifica di ripresa e chiede
# all'agente di misurare il drift, che e' il passo che un programma non puo' fare da se'.
#
# Perche' esiste, e che cosa lo distingue da session-context. Quell'hook stampa lo stato:
# branch, commit, file modificati, testa della memoria. Questo non stampa lo stato, lo
# CONFRONTA con quello che la sessione precedente aveva registrato, e la differenza e' tutta
# qui: una sessione caduta a meta' lascia un file di ripresa che descrive un passato, e un
# file di ripresa non aggiornato ha esattamente lo stesso aspetto di uno aggiornato. Nessuna
# stampa dello stato corrente rivela quella condizione: serve il confronto.
#
# I due hook si attivano insieme senza pestarsi, perche' rispondono a due domande diverse:
# "dove siamo" e "cio' che credo di sapere e' ancora vero".
#
# Il secondo mestiere di questo hook e' meno ovvio. L'uscita di un hook SessionStart entra nel
# contesto della sessione, quindi una riga di istruzione qui dentro e' il solo modo di rendere
# automatico un passo che richiede l'agente e non un programma: la misura del drift fra schede
# e codice la fa la skill sync-context, e nessun hook puo' invocare una skill.

$ErrorActionPreference = "SilentlyContinue"

$radice = if ($env:CLAUDE_PROJECT_DIR) { $env:CLAUDE_PROJECT_DIR } else { (Get-Location).Path }
$strumento = Join-Path $radice "tools\verifica-ripresa.py"

Write-Output "=== Verifica di ripresa ==="

if (-not (Test-Path $strumento)) {
    # Il progetto non ha istanziato lo strumento: si dichiara e non si blocca niente. Un hook
    # che fallisse qui renderebbe inutilizzabile un progetto che ha scelto di non averlo.
    Write-Output "tools/verifica-ripresa.py non e' istanziato in questo progetto: la verifica"
    Write-Output "di ripresa non e' disponibile. Si istanzia dal pacchetto del template."
} else {
    $uscita = & python $strumento 2>&1
    $esito = $LASTEXITCODE
    $uscita | ForEach-Object { Write-Output $_ }
    if ($esito -ne 0) {
        Write-Output ""
        Write-Output "ISTRUZIONE PER L'AGENTE: sopra ci sono divergenze fra il file di ripresa e"
        Write-Output "lo stato reale. Riportale all'utente PRIMA di qualunque altra cosa e prima"
        Write-Output "di leggere il file di ripresa, seguendo la skill riprendi: un file lasciato"
        Write-Output "a meta' puo' essere un lavoro da riprendere o uno da buttare, e la"
        Write-Output "differenza non si legge dal contenuto. Non decidere: chiedi."
    }
}

Write-Output ""
Write-Output "ISTRUZIONE PER L'AGENTE: come secondo atto della sessione invoca la skill"
Write-Output "sync-context, per misurare il drift fra le schede di .claude/context/ e il codice."
Write-Output "Nessun hook puo' invocare una skill, quindi questo passo dipende da te. Poi leggi"
Write-Output "le sole schede pertinenti al task, mai tutte insieme."

exit 0
