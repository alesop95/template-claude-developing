# Hook PreToolUse su Bash (variante Windows): quando il comando in arrivo e' un git commit,
# esegue la batteria di controlli che la convenzione prescrive prima di un commit, e blocca
# se uno fallisce.
#
# Quali controlli, e perche' proprio questi. Sono i quattro che verificano una convenzione
# dichiarata invece di un comportamento: la forma dei paragrafi Markdown, la tipografia, i
# comandi copiabili in una riga sola dentro i blocchi di codice, e i riferimenti a file che
# non esistono. Hanno in comune il modo di fallire, ed e' la ragione per cui vale automatizzarli
# proprio loro: nessuno dei quattro produce un errore visibile. Un paragrafo hard-wrapped
# sembra normale finche' il diff non ri-avvolge righe che nessuno ha toccato; un accento
# scritto con l'apostrofo si legge; un comando spezzato si copia e fallisce dopo; un documento
# che nomina un file inesistente non rompe niente e manda fuori strada chi lo legge.
#
# Che cosa NON copre, e va detto. Questo hook vede il git commit dell'agente. I commit manuali
# dell'utente non passano di qui, ed e' il caso normale in questo sistema, dove le operazioni
# git restano dell'utente: per coprirli serve un hook nativo di git, e il README del pacchetto
# spiega come. Vale quindi come rete e non come garanzia.
#
# Blocco = exit 2 con il motivo su stderr.

$ErrorActionPreference = "SilentlyContinue"

$raw = [Console]::In.ReadToEnd()
if ($raw -notmatch 'git\s+commit') { exit 0 }

$radice = if ($env:CLAUDE_PROJECT_DIR) { $env:CLAUDE_PROJECT_DIR } else { (Get-Location).Path }

# Ogni voce e' il nome del controllo, lo strumento e gli argomenti. Un controllo il cui
# strumento non e' istanziato si salta in silenzio: un progetto puo' legittimamente non avere
# quel pacchetto, e un hook che fallisse per questo renderebbe impossibile committare.
# Il perimetro e' la radice del progetto e non il punto: il punto si risolve sulla cartella
# corrente del processo che esegue l'hook, e le due coincidono in una sessione ordinaria ma non
# per contratto. Un controllo che girasse sulla cartella sbagliata non darebbe un errore, darebbe
# zero segnalazioni, cioe' un via libera indistinguibile da quello vero.
$controlli = @(
    @{ nome = "forma dei paragrafi Markdown"; file = "tools\md-unwrap.py";           args = @("--check", "--oracle", "require", $radice) },
    @{ nome = "accenti";                      file = "tools\fix-accents.py";         args = @("--check", $radice) },
    @{ nome = "trattini";                     file = "tools\fix-dashes.py";          args = @("--check", $radice) },
    @{ nome = "comandi copiabili";            file = "tools\lint-md-commands.py";    args = @($radice) },
    @{ nome = "riferimenti a file";           file = "tools\lint-doc-references.py"; args = @("--radice", $radice, "--solo-vivi") }
)

$falliti = @()
foreach ($c in $controlli) {
    $percorso = Join-Path $radice $c.file
    if (-not (Test-Path $percorso)) { continue }
    & python $percorso @($c.args) *> $null
    if ($LASTEXITCODE -ne 0) { $falliti += $c }
}

if ($falliti.Count -gt 0) {
    $righe = @("Controlli pre-commit falliti (hook pre-commit-checks). Il commit e' stato fermato.")
    foreach ($c in $falliti) {
        $righe += ("  - " + $c.nome + ": rilanciare  python " + $c.file + " " + ($c.args -join " "))
    }
    $righe += "Nessuno di questi produce un errore visibile se lo si ignora: e' la ragione per cui li controlla un programma."
    [Console]::Error.WriteLine(($righe -join "`n"))
    exit 2
}

exit 0
