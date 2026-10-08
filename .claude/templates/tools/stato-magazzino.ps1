# ============================================================================
# stato-magazzino.ps1
# Resoconto in sola lettura di cio' che resta nel magazzino nascosto di Claude Code,
# per tutti gli account della stessa utenza Windows, e delle sessioni ancora aperte.
#
# Perche' serve. Il wipe a fine sessione (session-end-wipe.ps1) si rimanda da solo se
# trova un'altra sessione di Claude Code viva, e scrive l'esito in un diario che nessuno
# legge. Il promemoria di chiusura diceva quindi "l'hook fa gia' il wipe" anche quando non
# aveva rimosso niente. Caso del 2026-10-08: account1 aveva cinque progetti in projects\,
# il diario diceva "Rimandato ... (PID 13528)", e quel processo era un claude.exe aperto da
# un giorno e mezzo che nessun file di sessione attribuiva a un account. Questo strumento
# mette insieme le tre cose che servono per decidere: che cosa resta, perche' e' rimasto,
# e quali sessioni aperte lo trattengono, con abbastanza testo di ciascuna sessione da
# riconoscerla.
#
# Che cosa mostra:
#   1. le sessioni di Claude Code aperte (CLI ed estensione dell'editor, non l'app
#      desktop), con avvio, terminale che le ospita, CPU e memoria, e il legame con un
#      account: CERTO quando esiste <account>\sessions\<pid>.json con lo stesso istante di
#      avvio del processo, IPOTESI quando manca e si propongono i verbali che hanno avuto
#      attivita' dopo l'avvio e che nessun'altra sessione viva rivendica;
#   2. per ogni account l'esito dell'ultimo wipe letto dal diario, i progetti rimasti in
#      projects\ con ogni sessione (titolo, prima e ultima richiesta, date, dimensione) e
#      le cartelle effimere ancora presenti;
#   3. gli scratchpad condivisi in %LOCALAPPDATA%\Temp\claude;
#   4. un riepilogo per account: quanto resta, perche', e il comando da lanciare.
#
# Non cancella nulla e non chiude nulla. L'unica azione possibile e' -Chiudi <PID>, che
# chiede di riscrivere il PID per conferma da tastiera: lanciato dall'agente, che non ha
# una tastiera, si ferma da solo. Un processo che non e' una sessione di Claude Code, o
# che e' un antenato di questo script, si rifiuta.
#
# I testi delle sessioni (titolo, richieste) stanno nei verbali e possono contenere dati
# personali: -SenzaTesti li omette e lascia solo date, dimensioni e identificativi.
#
# Uso:
#   powershell -NoProfile -ExecutionPolicy Bypass -File stato-magazzino.ps1
#   powershell -NoProfile -ExecutionPolicy Bypass -File stato-magazzino.ps1 -SenzaTesti
#   powershell -NoProfile -ExecutionPolicy Bypass -File stato-magazzino.ps1 -Chiudi 13528
#   powershell -NoProfile -ExecutionPolicy Bypass -File stato-magazzino.ps1 -Autotest
# ============================================================================
param(
  [string]$Radice = $env:USERPROFILE,                              # dove stanno le home .claude*
  [string]$TempClaude = (Join-Path $env:LOCALAPPDATA 'Temp\claude'),  # radice condivisa degli scratchpad
  [switch]$SenzaTesti,      # non mostra titoli e richieste delle sessioni
  [int]$Larghezza = 110,    # caratteri massimi per ogni testo citato
  [int]$Chiudi = 0,         # PID di una sessione da chiudere, con conferma da tastiera
  [switch]$Autotest
)
$ErrorActionPreference = 'Stop'
try { [Console]::OutputEncoding = [System.Text.Encoding]::UTF8 } catch {}

$script:Effimeri = @('sessions','session-env','shell-snapshots','file-history','plans','tasks',
                     'paste-cache','backups','memory','cache','jobs','ide','todos','statsig','telemetry')

# --- utilita' ---------------------------------------------------------------
function Format-Breve($s, $n) {
  if ($null -eq $s) { return '' }
  $t = ([string]$s) -replace '\s+', ' '
  $t = $t.Trim()
  if ($t.Length -gt $n) { $t = $t.Substring(0, $n - 3) + '...' }
  return $t
}
function Format-MB([long]$b) { return ('{0:N1} MB' -f ($b / 1MB)) }
function Format-Data($d) { if ($null -eq $d) { return '?' } return $d.ToString('dd/MM HH:mm') }
function Get-Dimensione($path) {
  $s = 0L
  Get-ChildItem -LiteralPath $path -Recurse -File -Force -ErrorAction SilentlyContinue |
    ForEach-Object { $s += $_.Length }
  return $s
}
function ConvertFrom-RigaJson($riga) {
  try { return ($riga | ConvertFrom-Json) } catch { return $null }
}

# --- lettura del magazzino --------------------------------------------------

# Un verbale e' un file .jsonl per sessione. Non si legge per intero: si cercano con
# Select-String le sole righe che Claude Code scrive per l'indice delle sessioni, cioe'
# 'ai-title' (il titolo generato) e 'last-prompt' (la richiesta piu' recente, una riga a
# ogni turno: la prima e' quindi la prima richiesta, l'ultima l'ultima), piu' la prima
# occorrenza di cwd e di timestamp.
function Read-Verbale($file) {
  $v = [ordered]@{
    Id = $file.BaseName; File = $file.FullName; Byte = $file.Length
    Ultima = $file.LastWriteTime; Prima = $null; Cwd = $null; Ramo = $null
    Titolo = $null; PrimaRichiesta = $null; UltimaRichiesta = $null; Turni = 0
  }
  $righe = @(Select-String -LiteralPath $file.FullName -Encoding UTF8 -Pattern '^\{"type":"(last-prompt|ai-title|custom-title)"' -ErrorAction SilentlyContinue)
  foreach ($r in $righe) {
    $o = ConvertFrom-RigaJson $r.Line
    if (-not $o) { continue }
    if ($o.type -eq 'last-prompt' -and $o.lastPrompt) {
      if (-not $v.PrimaRichiesta) { $v.PrimaRichiesta = $o.lastPrompt }
      $v.UltimaRichiesta = $o.lastPrompt
      $v.Turni++
    }
    elseif ($o.type -eq 'custom-title' -and $o.customTitle) { $v.Titolo = $o.customTitle }
    elseif ($o.type -eq 'ai-title' -and $o.aiTitle) { $v.Titolo = $o.aiTitle }
  }
  $m = Select-String -LiteralPath $file.FullName -Encoding UTF8 -Pattern '"timestamp":"([^"]+)"' -List -ErrorAction SilentlyContinue
  if ($m) { try { $v.Prima = ([datetime]::Parse($m.Matches[0].Groups[1].Value, [Globalization.CultureInfo]::InvariantCulture, [Globalization.DateTimeStyles]::RoundtripKind)).ToLocalTime() } catch {} }
  $m = Select-String -LiteralPath $file.FullName -Encoding UTF8 -Pattern '"cwd":"((?:[^"\\]|\\.)*)"' -List -ErrorAction SilentlyContinue
  if ($m) { $v.Cwd = $m.Matches[0].Groups[1].Value -replace '\\\\', '\' }
  $m = Select-String -LiteralPath $file.FullName -Encoding UTF8 -Pattern '"gitBranch":"([^"]*)"' -List -ErrorAction SilentlyContinue
  if ($m) { $v.Ramo = $m.Matches[0].Groups[1].Value }
  return [pscustomobject]$v
}

# Il diario dell'ultimo wipe: session-end-wipe.ps1 lo riscrive a ogni corsa, quindi dice
# l'esito dell'ultima, non la storia.
function Read-Diario($base) {
  $log = Join-Path $base 'session-end-wipe.log'
  $d = [ordered]@{ Presente = $false; Quando = $null; Modo = $null; Esito = 'nessun diario'; Pid = @(); Testo = $null }
  if (-not (Test-Path -LiteralPath $log)) { return [pscustomobject]$d }
  $d.Presente = $true
  $d.Quando = (Get-Item -LiteralPath $log).LastWriteTime
  $righe = @(Get-Content -LiteralPath $log -Encoding UTF8 | Where-Object { $_ })
  $testa = $righe | Where-Object { $_ -match '^session-end-wipe: (\S+ \S+)\s+modo=(\S+)' } | Select-Object -First 1
  if ($testa -and $testa -match '^session-end-wipe: (\S+ \S+)\s+modo=(\S+)') {
    try { $d.Quando = [datetime]::ParseExact($Matches[1], 'yyyy-MM-dd HH:mm:ss', $null) } catch {}
    $d.Modo = $Matches[2]
  }
  $rim = $righe | Where-Object { $_ -match '^Rimandato' } | Select-Object -First 1
  $abo = $righe | Where-Object { $_ -match '^ABORT' } | Select-Object -First 1
  if ($rim) {
    $d.Esito = 'rimandato'
    if ($rim -match '\(PID ([\d ,]+)\)') { $d.Pid = @($Matches[1] -split '[ ,]+' | Where-Object { $_ } | ForEach-Object { [int]$_ }) }
    $d.Testo = $rim
  }
  elseif ($abo) { $d.Esito = 'fermato'; $d.Testo = $abo }
  elseif ($righe -contains 'Fatto.') { $d.Esito = 'fatto' }
  else { $d.Esito = 'incompleto'; $d.Testo = ($righe | Select-Object -Last 1) }
  return [pscustomobject]$d
}

function Read-FileSessione($f, $account) {
  $o = ConvertFrom-RigaJson (Get-Content -LiteralPath $f.FullName -Raw -Encoding UTF8)
  if (-not $o -or -not $o.pid) { return $null }
  [pscustomobject]@{
    Account = $account; Pid = [int]$o.pid; SessionId = $o.sessionId; Cwd = $o.cwd
    Nome = $o.name; Stato = $o.status; Tipo = $o.kind; Ingresso = $o.entrypoint
    ProcStart = $(if ($o.procStart) { [long]$o.procStart } else { 0L })
    Aggiornato = $(if ($o.updatedAt) { [DateTimeOffset]::FromUnixTimeMilliseconds([long]$o.updatedAt).LocalDateTime } else { $null })
  }
}

function Read-Magazzino($radice, $tempClaude) {
  $account = @()
  $homes = @(Get-ChildItem -LiteralPath $radice -Directory -Force -Filter '.claude*' -ErrorAction SilentlyContinue |
    Where-Object { (Test-Path (Join-Path $_.FullName 'projects')) -or (Test-Path (Join-Path $_.FullName 'settings.json')) -or (Test-Path (Join-Path $_.FullName 'sessions')) })
  foreach ($h in $homes) {
    $nome = if ($h.Name -eq '.claude') { '.claude' } else { $h.Name -replace '^\.claude-', '' }
    $progetti = @()
    $p = Join-Path $h.FullName 'projects'
    if (Test-Path -LiteralPath $p) {
      foreach ($slug in @(Get-ChildItem -LiteralPath $p -Directory -Force)) {
        $verbali = @(Get-ChildItem -LiteralPath $slug.FullName -File -Filter '*.jsonl' -Force | Sort-Object LastWriteTime -Descending | ForEach-Object { Read-Verbale $_ })
        $progetti += [pscustomobject]@{
          Slug = $slug.Name; Byte = (Get-Dimensione $slug.FullName); Verbali = $verbali
          Ultima = $(if ($verbali) { $verbali[0].Ultima } else { $slug.LastWriteTime })
        }
      }
    }
    $sessioni = @()
    $sd = Join-Path $h.FullName 'sessions'
    if (Test-Path -LiteralPath $sd) {
      $sessioni = @(Get-ChildItem -LiteralPath $sd -File -Filter '*.json' -Force | ForEach-Object { Read-FileSessione $_ $nome } | Where-Object { $_ })
    }
    $effimeri = @()
    foreach ($e in $script:Effimeri) {
      $ep = Join-Path $h.FullName $e
      if (Test-Path -LiteralPath $ep) {
        $effimeri += [pscustomobject]@{ Nome = $e; Byte = (Get-Dimensione $ep); File = @(Get-ChildItem -LiteralPath $ep -Recurse -File -Force -ErrorAction SilentlyContinue).Count }
      }
    }
    $hist = Join-Path $h.FullName 'history.jsonl'
    if (Test-Path -LiteralPath $hist) { $effimeri += [pscustomobject]@{ Nome = 'history.jsonl'; Byte = (Get-Item -LiteralPath $hist).Length; File = 1 } }
    $account += [pscustomobject]@{
      Nome = $nome; Base = $h.FullName; Diario = (Read-Diario $h.FullName)
      Progetti = $progetti; Sessioni = $sessioni; Effimeri = $effimeri
      HaWipe = (Test-Path (Join-Path $h.FullName 'hooks\session-end-wipe.ps1'))
    }
  }
  $scratch = @()
  if ($tempClaude -and (Test-Path -LiteralPath $tempClaude)) {
    foreach ($slug in @(Get-ChildItem -LiteralPath $tempClaude -Directory -Force | Where-Object { $_.Name -match '^[A-Za-z]--' })) {
      $scratch += [pscustomobject]@{
        Slug = $slug.Name; Byte = (Get-Dimensione $slug.FullName)
        Sessioni = @(Get-ChildItem -LiteralPath $slug.FullName -Directory -Force | ForEach-Object { $_.Name })
        Ultima = $slug.LastWriteTime
      }
    }
  }
  return [pscustomobject]@{ Account = $account; Scratchpad = $scratch }
}

# --- processi ----------------------------------------------------------------

# Stesso criterio della guardia 0.4 di session-end-wipe.ps1, cosi' che i PID mostrati qui
# siano esattamente quelli che il wipe conta: claude.exe fuori da WindowsApps e senza
# --type= (l'app desktop e i suoi ausiliari restano fuori), piu' le installazioni via node.
function Get-ProcessiClaude {
  $tutti = @(Get-CimInstance Win32_Process -ErrorAction SilentlyContinue)
  $perPid = @{}
  foreach ($p in $tutti) { $perPid[[int]$p.ProcessId] = $p }
  $antenati = @{}
  $cur = [int]$PID; $passi = 0
  while ($perPid.ContainsKey($cur) -and $passi -lt 64) { $antenati[$cur] = $true; $cur = [int]$perPid[$cur].ParentProcessId; $passi++ }
  $sel = @($tutti | Where-Object {
    $cmd = [string]$_.CommandLine; $exe = [string]$_.ExecutablePath
    (($_.Name -eq 'claude.exe') -and ($exe -notmatch '\\WindowsApps\\') -and ($cmd -notmatch '--type=')) -or
    (($_.Name -match '^node(\.exe)?$') -and ($cmd -match '@anthropic-ai[\\/]claude-code'))
  })
  foreach ($p in $sel) {
    $catena = @(); $c = [int]$p.ParentProcessId; $n = 0
    while ($perPid.ContainsKey($c) -and $n -lt 3) { $q = $perPid[$c]; $catena += ('{0} {1}' -f ($q.Name -replace '\.exe$', ''), $c); $c = [int]$q.ParentProcessId; $n++ }
    if (-not $perPid.ContainsKey([int]$p.ParentProcessId)) { $catena += ('genitore {0} terminato' -f $p.ParentProcessId) }
    $gp = Get-Process -Id $p.ProcessId -ErrorAction SilentlyContinue
    [pscustomobject]@{
      Pid = [int]$p.ProcessId; Avvio = $p.CreationDate
      AvvioFileTime = $(if ($p.CreationDate) { $p.CreationDate.ToFileTimeUtc() } else { 0L })
      Catena = ($catena -join ' > '); Cpu = $(if ($gp) { [int]$gp.CPU } else { $null })
      RamMB = $(if ($gp) { [int]($gp.WorkingSet64 / 1MB) } else { $null })
      Proprio = $antenati.ContainsKey([int]$p.ProcessId)
    }
  }
}

# Lega ogni processo a una sessione. CERTO: un file sessions\<pid>.json il cui procStart
# coincide con l'avvio del processo entro due secondi; un PID riusato da un processo nuovo
# ha lo stesso numero ma un altro avvio, e non deve ereditare il file del vecchio. IPOTESI:
# i verbali con attivita' dopo l'avvio del processo che nessuna sessione legata con
# certezza rivendica, prima quelli nati dopo l'avvio (una sessione nuova), poi gli altri
# (una sessione ripresa con --resume continua un verbale piu' vecchio).
function Get-Legami($processi, $magazzino) {
  $tolleranza = 20000000L
  $file = @($magazzino.Account | ForEach-Object { $_.Sessioni })
  $tuttiVerbali = @()
  foreach ($a in $magazzino.Account) { foreach ($p in $a.Progetti) { foreach ($v in $p.Verbali) {
    $tuttiVerbali += [pscustomobject]@{ Account = $a.Nome; Slug = $p.Slug; Verbale = $v }
  } } }
  $legami = @()
  foreach ($pr in $processi) {
    $f = $file | Where-Object { $_.Pid -eq $pr.Pid -and ($_.ProcStart -eq 0 -or [math]::Abs($_.ProcStart - $pr.AvvioFileTime) -le $tolleranza) } | Select-Object -First 1
    $legami += [pscustomobject]@{ Processo = $pr; File = $f; Certo = [bool]$f; Candidati = @() }
  }
  $rivendicati = @{}
  foreach ($l in $legami) { if ($l.Certo -and $l.File.SessionId) { $rivendicati[$l.File.SessionId] = $true } }
  foreach ($l in $legami) {
    if ($l.Certo) { continue }
    $avvio = $l.Processo.Avvio
    $c = @($tuttiVerbali | Where-Object { -not $rivendicati.ContainsKey($_.Verbale.Id) -and $_.Verbale.Ultima -ge $avvio })
    $nuovi = @($c | Where-Object { $_.Verbale.Prima -and $_.Verbale.Prima -ge $avvio.AddMinutes(-1) } | Sort-Object { $_.Verbale.Prima })
    $ripresi = @($c | Where-Object { -not ($_.Verbale.Prima -and $_.Verbale.Prima -ge $avvio.AddMinutes(-1)) } | Sort-Object { $_.Verbale.Ultima } -Descending)
    $l.Candidati = @($nuovi + $ripresi)
  }
  return $legami
}

# --- stampa ------------------------------------------------------------------
function Write-Testi($v, $rientro) {
  if ($SenzaTesti) { return }
  $tit = if ($v.Titolo) { Format-Breve $v.Titolo $Larghezza } else { '(nessun titolo)' }
  Write-Host ("{0}titolo:           {1}" -f $rientro, $tit)
  if ($v.PrimaRichiesta) {
    Write-Host ("{0}prima richiesta:  {1}" -f $rientro, (Format-Breve $v.PrimaRichiesta $Larghezza))
    if ($v.Turni -gt 1) { Write-Host ("{0}ultima richiesta: {1}" -f $rientro, (Format-Breve $v.UltimaRichiesta $Larghezza)) }
  }
  else { Write-Host ("{0}(nessuna richiesta registrata)" -f $rientro) }
}

function Write-Resoconto($magazzino, $legami) {
  $vivi = @{}
  foreach ($l in $legami) { $vivi[$l.Processo.Pid] = $l }
  $sessioneViva = @{}
  foreach ($l in $legami) { if ($l.Certo) { $sessioneViva[$l.File.SessionId] = $l.Processo.Pid } }

  Write-Host ''
  Write-Host ("== Magazzino nascosto di Claude Code, {0} (sola lettura)" -f (Get-Date -Format 'yyyy-MM-dd HH:mm')) -ForegroundColor Cyan

  Write-Host ''
  Write-Host ("-- Sessioni di Claude Code aperte: {0}" -f $legami.Count) -ForegroundColor Cyan
  if (-not $legami) { Write-Host '   nessuna: il wipe di ogni account puo'' girare senza rinvio.' }
  foreach ($l in ($legami | Sort-Object { $_.Processo.Avvio })) {
    $pr = $l.Processo
    $acc = if ($l.Certo) { $l.File.Account } else { '?' }
    $leg = if ($l.Certo) { 'certo' } else { 'ipotesi' }
    $mio = if ($pr.Proprio) { '   [e'' la sessione che esegue questo script]' } else { '' }
    Write-Host ''
    Write-Host ("   PID {0}   avviata {1}   account {2} ({3})   CPU {4} s   RAM {5} MB{6}" -f $pr.Pid, (Format-Data $pr.Avvio), $acc, $leg, $pr.Cpu, $pr.RamMB, $mio) -ForegroundColor Yellow
    Write-Host ("      terminale:  {0}" -f $pr.Catena)
    if ($l.Certo) {
      $f = $l.File
      Write-Host ("      progetto:   {0}   nome {1}   stato {2}   aggiornato {3}" -f $f.Cwd, $f.Nome, $f.Stato, (Format-Data $f.Aggiornato))
      $v = $null
      foreach ($a in $magazzino.Account) { foreach ($p in $a.Progetti) { foreach ($x in $p.Verbali) { if ($x.Id -eq $f.SessionId) { $v = $x } } } }
      if ($v) {
        Write-Host ("      sessione:   {0}   dal {1}   ultima attivita' {2}   {3}" -f $v.Id, (Format-Data $v.Prima), (Format-Data $v.Ultima), (Format-MB $v.Byte))
        Write-Testi $v '      '
      }
      else { Write-Host ("      sessione:   {0}   (verbale non ancora scritto)" -f $f.SessionId) }
    }
    else {
      Write-Host '      nessun file sessions\<pid>.json in nessun account con questo avvio: il legame non e'' dimostrabile.'
      Write-Host '      cause possibili: la sessione scrive in una home fuori da questa radice (claude-incognito, un altro CLAUDE_CONFIG_DIR), oppure il suo file e'' stato tolto da un wipe forzato. I verbali qui sotto sono indizi, non prove: riconoscila dal suo terminale.'
      if ($l.Candidati) {
        Write-Host ("      verbali con attivita' dopo l'avvio e non rivendicati da altre sessioni ({0}), i primi tre:" -f $l.Candidati.Count)
        foreach ($c in ($l.Candidati | Select-Object -First 3)) {
          $v = $c.Verbale
          $nuovo = if ($v.Prima -and $v.Prima -ge $pr.Avvio.AddMinutes(-1)) { 'nato dopo l''avvio' } else { 'piu'' vecchio, forse ripreso' }
          Write-Host ("        - {0} / {1} / {2}   dal {3}   ultima {4}   ({5})" -f $c.Account, $c.Slug, $v.Id.Substring(0, [math]::Min(8, $v.Id.Length)), (Format-Data $v.Prima), (Format-Data $v.Ultima), $nuovo)
          Write-Testi $v '          '
        }
      }
      else { Write-Host '      nessun verbale ha avuto attivita'' dopo l''avvio: e'' una sessione che non ha mai ricevuto una richiesta, oppure scrive in una home fuori da questa radice.' }
    }
    if (-not $pr.Proprio) {
      Write-Host ("      per chiuderla, dopo averla riconosciuta: powershell -NoProfile -ExecutionPolicy Bypass -File `"{0}`" -Chiudi {1}" -f $PSCommandPath, $pr.Pid) -ForegroundColor DarkGray
    }
  }

  foreach ($a in $magazzino.Account) {
    Write-Host ''
    Write-Host ("-- {0}   {1}" -f $a.Nome, $a.Base) -ForegroundColor Cyan
    $d = $a.Diario
    if (-not $a.HaWipe) { Write-Host '   wipe non installato in questo account (hooks\session-end-wipe.ps1 assente).' -ForegroundColor DarkYellow }
    if ($d.Presente) {
      $det = switch ($d.Esito) {
        'fatto'      { 'completato' }
        'rimandato'  { 'rimandato, nessuna rimozione: ' + (($d.Pid | ForEach-Object { if ($vivi.ContainsKey($_)) { "PID $_ ancora aperto" } else { "PID $_ ora chiuso" } }) -join ', ') }
        'fermato'    { 'fermato da una guardia: ' + (Format-Breve $d.Testo $Larghezza) }
        default      { 'interrotto, ultima riga: ' + (Format-Breve $d.Testo $Larghezza) }
      }
      Write-Host ("   ultimo wipe: {0}  modo {1}  {2}" -f (Format-Data $d.Quando), $d.Modo, $det)
    }
    else { Write-Host '   ultimo wipe: nessun diario, il wipe non e'' mai girato qui.' }
    $nv = ($a.Progetti | ForEach-Object { $_.Verbali.Count } | Measure-Object -Sum).Sum
    $nb = ($a.Progetti | ForEach-Object { $_.Byte } | Measure-Object -Sum).Sum
    Write-Host ("   projects\: {0} progetti, {1} sessioni, {2}" -f $a.Progetti.Count, [int]$nv, (Format-MB ([long]$nb)))
    foreach ($p in ($a.Progetti | Sort-Object Ultima -Descending)) {
      Write-Host ''
      Write-Host ("   {0}   {1} sessioni   {2}   ultima {3}" -f $p.Slug, $p.Verbali.Count, (Format-MB $p.Byte), (Format-Data $p.Ultima)) -ForegroundColor White
      foreach ($v in $p.Verbali) {
        $vivo = if ($sessioneViva.ContainsKey($v.Id)) { "   [aperta, PID $($sessioneViva[$v.Id])]" }
                elseif ($d.Quando -and $v.Ultima -gt $d.Quando) { '   [dopo l''ultimo wipe]' } else { '' }
        $ramo = if ($v.Ramo) { "   ramo $($v.Ramo)" } else { '' }
        Write-Host ("     - {0}   {1} -> {2}   {3}   {4} richieste{5}{6}" -f $v.Id.Substring(0, [math]::Min(8, $v.Id.Length)), (Format-Data $v.Prima), (Format-Data $v.Ultima), (Format-MB $v.Byte), $v.Turni, $ramo, $vivo)
        Write-Testi $v '         '
      }
    }
    if ($a.Effimeri) {
      Write-Host ''
      Write-Host ('   effimeri: ' + (($a.Effimeri | ForEach-Object { '{0} {1} file {2}' -f $_.Nome, $_.File, (Format-MB $_.Byte) }) -join ' | '))
    }
  }

  Write-Host ''
  Write-Host ("-- Scratchpad condivisi   {0}" -f $TempClaude) -ForegroundColor Cyan
  if (-not $magazzino.Scratchpad) { Write-Host '   nessuno.' }
  foreach ($s in ($magazzino.Scratchpad | Sort-Object Ultima -Descending)) {
    $aperte = @($s.Sessioni | Where-Object { $sessioneViva.ContainsKey($_) } | ForEach-Object { "PID $($sessioneViva[$_])" })
    $tag = if ($aperte) { '   [in uso: ' + ($aperte -join ', ') + ']' } else { '' }
    Write-Host ("   {0}   {1} sessioni   {2}   ultima {3}{4}" -f $s.Slug, $s.Sessioni.Count, (Format-MB $s.Byte), (Format-Data $s.Ultima), $tag)
  }

  Write-Host ''
  Write-Host '-- Riepilogo: che cosa resta e perche''' -ForegroundColor Cyan
  foreach ($a in $magazzino.Account) {
    $nv = [int](($a.Progetti | ForEach-Object { $_.Verbali.Count } | Measure-Object -Sum).Sum)
    if ($a.Progetti.Count -eq 0 -and -not $a.Effimeri) { Write-Host ("   {0}: pulito." -f $a.Nome); continue }
    $d = $a.Diario
    $proprie = @($legami | Where-Object { $_.Certo -and $_.File.Account -eq $a.Nome })
    $perche = if (-not $a.HaWipe) { 'il wipe non e'' installato' }
      elseif ($d.Esito -eq 'rimandato') {
        $ancora = @($d.Pid | Where-Object { $vivi.ContainsKey($_) })
        if ($ancora) { 'ultimo wipe rimandato per i PID ' + ($ancora -join ', ') + ', ancora aperti' }
        else { 'ultimo wipe rimandato, ma i PID che lo bloccavano ora sono chiusi: rilancialo' }
      }
      elseif ($d.Esito -eq 'fermato') { 'ultimo wipe fermato da una guardia, vedi sopra' }
      elseif ($a.Progetti.Count -eq 0) { 'solo cartelle effimere, scritte dopo l''ultimo wipe' }
      elseif ($proprie) { 'sessioni dell''account ancora aperte (PID ' + (($proprie | ForEach-Object { $_.Processo.Pid }) -join ', ') + ')' }
      else { 'sessioni chiuse dopo l''ultimo wipe' }
    Write-Host ("   {0}: {1} progetti, {2} sessioni; {3}." -f $a.Nome, $a.Progetti.Count, $nv, $perche)
    if ($a.HaWipe) {
      $altre = @($legami | Where-Object { -not $_.Processo.Proprio })
      $forza = if ($altre) { ' -Forza' } else { '' }
      Write-Host ("      powershell -NoProfile -ExecutionPolicy Bypass -File `"{0}`"{1}" -f (Join-Path $a.Base 'hooks\session-end-wipe.ps1'), $forza) -ForegroundColor DarkGray
    }
  }
  $altre = @($legami | Where-Object { -not $_.Processo.Proprio })
  if ($altre) {
    Write-Host ''
    Write-Host ("   Con {0} sessioni aperte il wipe si rimanda; -Forza lo esegue comunque e toglie scratchpad, piani e task anche a quelle sessioni. Prima riconoscile qui sopra, poi chiudile dal loro terminale o con -Chiudi." -f $altre.Count)
  }
  Write-Host ''
}

# --- chiusura su conferma ----------------------------------------------------
function Test-Chiudibile($pidScelto, $processi) {
  $p = @($processi | Where-Object { $_.Pid -eq $pidScelto })
  if (-not $p) { return "il PID $pidScelto non e' una sessione di Claude Code aperta: rifiuto." }
  if ($p[0].Proprio) { return "il PID $pidScelto e' la sessione da cui gira questo script: rifiuto." }
  return $null
}

# --- autotest ----------------------------------------------------------------
# Ogni caso positivo ha un gemello negativo che differisce per una sola proprieta', cosi'
# che una prova verde dica che la proprieta' e' stata davvero esercitata.
function Invoke-Autotest {
  $tmp = Join-Path ([IO.Path]::GetTempPath()) ('stato-magazzino-prova-' + [guid]::NewGuid().ToString('N').Substring(0, 8))
  function Atteso($nome, $cond) { $script:casiT++; if ($cond) { Write-Host "  ok    $nome" } else { $script:falliT++; Write-Host "  FALLITO $nome" -ForegroundColor Red } }
  $script:casiT = 0; $script:falliT = 0
  try {
    $acc = Join-Path $tmp '.claude-accountP'
    $proj = Join-Path $acc 'projects\E--prova'
    New-Item -ItemType Directory -Force -Path $proj, (Join-Path $acc 'sessions'), (Join-Path $acc 'hooks'), (Join-Path $acc 'plans') | Out-Null
    Set-Content -LiteralPath (Join-Path $acc 'hooks\session-end-wipe.ps1') -Value '#' -Encoding ascii
    Set-Content -LiteralPath (Join-Path $acc 'plans\p.md') -Value 'x' -Encoding ascii
    $avvio = (Get-Date).AddHours(-2)
    $ts = { param($d) $d.ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ss.fffZ') }
    $utf8 = New-Object System.Text.UTF8Encoding($false)
    $scrivi = { param($nome, $righe, $ultima) $f = Join-Path $proj "$nome.jsonl"; [IO.File]::WriteAllLines($f, [string[]]$righe, $utf8); (Get-Item $f).LastWriteTime = $ultima }
    # A: legato con certezza al processo 111
    & $scrivi 'aaaaaaaa-1' @(
      ('{"type":"queue-operation","timestamp":"' + (& $ts $avvio.AddMinutes(1)) + '"}'),
      '{"type":"user","cwd":"E:\\prova","gitBranch":"main","timestamp":"x"}',
      ('{"type":"last-prompt","lastPrompt":"prima richiesta di A con citt' + [char]0x00E0 + '","sessionId":"aaaaaaaa-1"}'),
      '{"type":"ai-title","aiTitle":"Titolo provvisorio","sessionId":"aaaaaaaa-1"}',
      '{"type":"last-prompt","lastPrompt":"ultima richiesta di A","sessionId":"aaaaaaaa-1"}',
      '{"type":"ai-title","aiTitle":"Titolo finale di A","sessionId":"aaaaaaaa-1"}') (Get-Date)
    # B: nato dopo l'avvio del processo 222, che non ha file di sessione
    & $scrivi 'bbbbbbbb-2' @(('{"type":"queue-operation","timestamp":"' + (& $ts $avvio.AddMinutes(5)) + '"}'),
      '{"type":"last-prompt","lastPrompt":"richiesta di B","sessionId":"bbbbbbbb-2"}') (Get-Date)
    # C: gemello di B che ha smesso di scrivere prima dell'avvio di 222
    & $scrivi 'cccccccc-3' @(('{"type":"queue-operation","timestamp":"' + (& $ts $avvio.AddHours(-5)) + '"}')) $avvio.AddHours(-1)
    # D: nessuna richiesta registrata; nato prima dell'avvio e attivo dopo, come una sessione ripresa
    & $scrivi 'dddddddd-4' @(('{"type":"queue-operation","timestamp":"' + (& $ts $avvio.AddHours(-3)) + '"}')) (Get-Date)
    $ft = $avvio.ToFileTimeUtc()
    Set-Content -LiteralPath (Join-Path $acc 'sessions\111.json') -Encoding ascii -Value ('{"pid":111,"sessionId":"aaaaaaaa-1","cwd":"E:\\prova","procStart":"' + $ft + '","name":"prova","status":"idle"}')
    Set-Content -LiteralPath (Join-Path $acc 'sessions\333.json') -Encoding ascii -Value ('{"pid":333,"sessionId":"dddddddd-4","cwd":"E:\\prova","procStart":"' + ($ft - 864000000000L) + '","name":"vecchio"}')
    Set-Content -LiteralPath (Join-Path $acc 'session-end-wipe.log') -Encoding utf8 -Value @('session-end-wipe: 2026-10-08 17:56:48  modo=wipe  base=x', 'Progetti: 1 totali', 'Rimandato: 2 altre sessioni di Claude Code aperte (PID 111, 444). Le cartelle...', 'Nessuna rimozione eseguita.')
    $acc2 = Join-Path $tmp '.claude-accountQ'
    New-Item -ItemType Directory -Force -Path (Join-Path $acc2 'projects') | Out-Null
    Set-Content -LiteralPath (Join-Path $acc2 'session-end-wipe.log') -Encoding utf8 -Value @('session-end-wipe: 2026-10-08 08:33:01  modo=wipe  base=y', 'Progetti: 0 totali', 'Fatto.')

    $m = Read-Magazzino $tmp $null
    $P = $m.Account | Where-Object { $_.Nome -eq 'accountP' }
    $Q = $m.Account | Where-Object { $_.Nome -eq 'accountQ' }
    $vA = $P.Progetti[0].Verbali | Where-Object { $_.Id -eq 'aaaaaaaa-1' }
    $vD = $P.Progetti[0].Verbali | Where-Object { $_.Id -eq 'dddddddd-4' }
    Atteso 'trovati due account nella radice' ($m.Account.Count -eq 2)
    Atteso 'prima richiesta = primo last-prompt, accento intatto' ($vA.PrimaRichiesta -eq ('prima richiesta di A con citt' + [char]0x00E0))
    Atteso 'ultima richiesta = ultimo last-prompt' ($vA.UltimaRichiesta -eq 'ultima richiesta di A')
    Atteso 'titolo = ultimo ai-title, non il primo' ($vA.Titolo -eq 'Titolo finale di A')
    Atteso 'cwd con barra singola e ramo letti' ($vA.Cwd -eq 'E:\prova' -and $vA.Ramo -eq 'main')
    Atteso 'verbale senza richieste: zero turni e nessun testo' ($vD.Turni -eq 0 -and -not $vD.PrimaRichiesta)
    Atteso 'diario rimandato con due PID' ($P.Diario.Esito -eq 'rimandato' -and ($P.Diario.Pid -join ',') -eq '111,444')
    Atteso 'diario fatto' ($Q.Diario.Esito -eq 'fatto')
    Atteso 'effimero plans contato' (@($P.Effimeri | Where-Object { $_.Nome -eq 'plans' }).Count -eq 1)

    $proc = @(
      [pscustomobject]@{ Pid = 111; Avvio = $avvio; AvvioFileTime = $ft; Catena = 'x'; Cpu = 1; RamMB = 1; Proprio = $false },
      [pscustomobject]@{ Pid = 222; Avvio = $avvio; AvvioFileTime = $ft; Catena = 'x'; Cpu = 1; RamMB = 1; Proprio = $false },
      [pscustomobject]@{ Pid = 333; Avvio = $avvio; AvvioFileTime = $ft; Catena = 'x'; Cpu = 1; RamMB = 1; Proprio = $true })
    $leg = Get-Legami $proc $m
    $l111 = $leg | Where-Object { $_.Processo.Pid -eq 111 }
    $l222 = $leg | Where-Object { $_.Processo.Pid -eq 222 }
    $l333 = $leg | Where-Object { $_.Processo.Pid -eq 333 }
    $ids222 = @($l222.Candidati | ForEach-Object { $_.Verbale.Id })
    Atteso 'PID con file di sessione e stesso avvio: legame certo' ($l111.Certo -and $l111.File.Account -eq 'accountP')
    Atteso 'PID con file di sessione ma avvio diverso (PID riusato): non certo' (-not $l333.Certo)
    Atteso 'PID senza file: verbale nato dopo l''avvio proposto per primo' ($ids222.Count -gt 0 -and $ids222[0] -eq 'bbbbbbbb-2')
    Atteso 'PID senza file: verbale fermo prima dell''avvio escluso' ($ids222 -notcontains 'cccccccc-3')
    Atteso 'PID senza file: verbale rivendicato da un''altra sessione escluso' ($ids222 -notcontains 'aaaaaaaa-1')
    Atteso 'PID senza file: verbale ripreso proposto dopo quelli nati dopo l''avvio' ($ids222.Count -eq 2 -and $ids222[1] -eq 'dddddddd-4')
    Atteso '-Chiudi rifiuta un PID che non e'' una sessione' ([bool](Test-Chiudibile 999 $proc))
    Atteso '-Chiudi rifiuta la sessione da cui gira lo script' ([bool](Test-Chiudibile 333 $proc))
    Atteso '-Chiudi accetta una sessione altrui' (-not (Test-Chiudibile 222 $proc))
  }
  finally { Remove-Item -LiteralPath $tmp -Recurse -Force -ErrorAction SilentlyContinue }
  Write-Host ("autotest: {0} casi, {1} falliti" -f $script:casiT, $script:falliT)
  if ($script:falliT -gt 0) { exit 1 } else { exit 0 }
}

# --- principale --------------------------------------------------------------
if ($Autotest) { Invoke-Autotest }

$processi = @(Get-ProcessiClaude)

if ($Chiudi -gt 0) {
  $no = Test-Chiudibile $Chiudi $processi
  if ($no) { Write-Host $no -ForegroundColor Red; exit 1 }
  $magazzino = Read-Magazzino $Radice $TempClaude
  $legami = @(Get-Legami $processi $magazzino | Where-Object { $_.Processo.Pid -eq $Chiudi })
  Write-Resoconto $magazzino $legami
  Write-Host "Chiudere il PID $Chiudi termina la sessione senza che il suo hook SessionEnd parta: il verbale resta e il wipe va rilanciato dopo."
  try { $r = Read-Host "Per confermare riscrivi il PID ($Chiudi), qualunque altra risposta annulla" }
  catch { Write-Host 'nessuna tastiera disponibile: annullato.' -ForegroundColor Red; exit 1 }
  if ($r -ne [string]$Chiudi) { Write-Host 'annullato, nessun processo chiuso.'; exit 0 }
  Stop-Process -Id $Chiudi -ErrorAction Stop
  Write-Host "PID $Chiudi chiuso." -ForegroundColor Green
  exit 0
}

$magazzino = Read-Magazzino $Radice $TempClaude
$legami = @(Get-Legami $processi $magazzino)
Write-Resoconto $magazzino $legami
exit 0
