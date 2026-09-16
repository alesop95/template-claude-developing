# Hook PostToolUse su Write ed Edit (variante Windows): riporta i paragrafi del file appena
# scritto su riga sorgente unica, secondo la convenzione della regola interaction-style.
#
# Perche' e' un hook e non una consegna all'agente. La convenzione dice di eseguire lo
# strumento dopo aver scritto o modificato un file Markdown, e quella prescrizione ha lo stesso
# difetto di tutte le prescrizioni che dipendono dal ricordarsene: funziona finche' qualcuno
# ricorda, e la volta che non ricorda nessuno se ne accorge, perche' un file hard-wrapped non
# sembra sbagliato. Se ne accorge il diff del commit successivo, che ri-avvolge righe che
# nessuno ha toccato, e a quel punto il rumore e' gia' entrato nella storia.
#
# Agisce dopo la scrittura e non prima, perche' e' una normalizzazione e non una difesa: non
# c'e' niente da bloccare, c'e' una forma da attuare. Per contratto lo strumento rifiuta di
# scrivere un file il cui rendering cambierebbe, quindi il caso peggiore e' che non faccia
# nulla, mai che rovini un file.
#
# Tocca soltanto i file .md, e soltanto dentro la radice del progetto.

$ErrorActionPreference = "SilentlyContinue"

$raw = [Console]::In.ReadToEnd()
if (-not $raw) { exit 0 }

try { $payload = $raw | ConvertFrom-Json } catch { exit 0 }
$percorso = $payload.tool_input.file_path
if (-not $percorso) { exit 0 }
if ($percorso -notmatch '\.md$') { exit 0 }
if (-not (Test-Path $percorso)) { exit 0 }

$radice = if ($env:CLAUDE_PROJECT_DIR) { $env:CLAUDE_PROJECT_DIR } else { (Get-Location).Path }
$strumento = Join-Path $radice "tools\md-unwrap.py"
if (-not (Test-Path $strumento)) { exit 0 }

# Il marcatore che esenta una cartella dalla normalizzazione lo rispetta lo strumento stesso:
# qui non si duplica quella logica, perche' due copie della stessa regola divergono.
& python $strumento $percorso *> $null

exit 0
