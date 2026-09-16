# Hook SessionEnd (variante Windows): registra l'impronta di ripresa come ultimo atto della
# sessione, cosi' che la sessione successiva possa sapere se questa si sia chiusa davvero.
#
# Il paradosso che questo hook risolve a meta', e che va capito prima di attivarlo. L'impronta
# serve a distinguere una sessione chiusa bene da una caduta; ma se la registrasse solo
# l'agente, una sessione caduta non la registrerebbe mai, che e' proprio il comportamento
# voluto. Se invece la registra un hook di chiusura, la registra anche quando la finestra viene
# chiusa di colpo, e allora una caduta diventa indistinguibile da una chiusura ordinata.
#
# La risoluzione sta in che cosa l'hook scrive. Un hook SessionEnd gira alla chiusura della
# sessione, comprese quelle ordinate, ma NON gira quando il processo muore per un crash vero o
# una interruzione dell'alimentazione, che sono i casi che contano di piu'. Quindi questo hook
# copre la chiusura distratta, cioe' la finestra chiusa senza aver aggiornato il file di
# ripresa, e lascia scoperta la caduta vera, che e' esattamente cio' che si vuole sia visibile.
#
# Ne discende una prescrizione d'uso, scritta anche nel README: questo hook e' una rete, non il
# percorso principale. Il percorso principale resta l'agente che, a fine sessione, aggiorna il
# file di ripresa con lo stato raggiunto e il prossimo passo, e poi registra. Un'impronta
# registrata senza quell'aggiornamento dice che lo stato di git e' noto e non dice dove eravamo.

$ErrorActionPreference = "SilentlyContinue"

$radice = if ($env:CLAUDE_PROJECT_DIR) { $env:CLAUDE_PROJECT_DIR } else { (Get-Location).Path }
$strumento = Join-Path $radice "tools\verifica-ripresa.py"
if (-not (Test-Path $strumento)) { exit 0 }

& python $strumento --registra *> $null

exit 0
