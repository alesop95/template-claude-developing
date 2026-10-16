#!/usr/bin/env bash
# Banco di prova di colibri: misura un modello con un tetto di RAM dato, e registra parole al secondo, memoria massima e byte letti dal disco.
# Non scarica modelli e non installa colibri. Non modifica il sistema oltre a svuotare la cache dei file (serve sudo) e a copiare il modello su ext4.
# Lo scaffold isola l'invocazione di colibri nella funzione genera_e_misura: va allineata al protocollo ufficiale docs/benchmarking.md del repository colibri prima della prima corsa vera.
set -euo pipefail

VALORI=""
MODELLO=""
RAM=""
while [ $# -gt 0 ]; do
  case "$1" in
    --valori) VALORI="$2"; shift 2 ;;
    --modello) MODELLO="$2"; shift 2 ;;
    --ram) RAM="$2"; shift 2 ;;
    *) echo "argomento sconosciuto: $1" >&2; exit 2 ;;
  esac
done
[ -n "$VALORI" ] && [ -n "$MODELLO" ] && [ -n "$RAM" ] || { echo "uso: bench-colibri.sh --valori <file> --modello <nome> --ram <tetto, es. 16G>" >&2; exit 2; }
[ -f "$VALORI" ] || { echo "file dei valori assente: $VALORI" >&2; exit 2; }
# shellcheck disable=SC1090
. "$VALORI"

[ -n "${MODELLI[$MODELLO]:-}" ] || { echo "modello non in tabella: $MODELLO" >&2; exit 2; }
command -v systemd-run >/dev/null || { echo "systemd-run assente: serve systemd per limitare la RAM del solo processo" >&2; exit 2; }
[ -x "$COLI_DIR/coli" ] || { echo "motore colibri non compilato in $COLI_DIR/coli" >&2; exit 2; }

SRC="$MAGAZZINO/${MODELLI[$MODELLO]}"
[ -d "$SRC" ] || { echo "modello non presente nel magazzino: $SRC" >&2; exit 2; }

# Copia su ext4 veloce, una volta: dentro WSL il modello non deve stare su /mnt/c o la misura delle letture dal disco e' falsata.
RUNDIR="$SRC"
if [ "${COPIA_IN_EXT4:-0}" = "1" ]; then
  RUNDIR="$EXT4_SCRATCH/${MODELLI[$MODELLO]}"
  if [ ! -d "$RUNDIR" ]; then
    echo "copio il modello su ext4: $RUNDIR (una volta sola)"
    mkdir -p "$RUNDIR"
    cp -r "$SRC/." "$RUNDIR/"
  fi
fi

mkdir -p "$MISURE"
SCOPE="colibri-bench-$MODELLO-$RAM-$$"
TMP_OUT="$(mktemp)"
trap 'rm -f "$TMP_OUT"' EXIT

# Svuota la cache dei file prima della corsa, cosi' gli esperti si leggono davvero dal disco. Richiede privilegio.
svuota_cache() {
  if [ "$(id -u)" = "0" ]; then sync; echo 3 > /proc/sys/vm/drop_caches
  elif sudo -n true 2>/dev/null; then sync; sudo sh -c 'echo 3 > /proc/sys/vm/drop_caches'
  else echo "ATTENZIONE: cache dei file non svuotata (serve sudo). La prima misura sara' ottimistica." >&2; fi
}

# L'unica parte specifica di colibri. Deve generare TOKEN_DA_GENERARE parole dal PROMPT_PROVA e stampare le parole al secondo in decodifica.
# Da completare con il comando reale dopo aver letto docs/benchmarking.md del repository colibri. Qui resta un segnaposto che fallisce apposta.
genera_e_misura() {
  cd "$COLI_DIR"
  # ./coli tune --model "$RUNDIR"   # si lancia una volta per configurazione, sceglie le impostazioni in base alla RAM vista
  # ESEMPIO da adattare al protocollo ufficiale:
  #   ./coli run --model "$RUNDIR" --prompt "$PROMPT_PROVA" --max-tokens "$TOKEN_DA_GENERARE" --bench
  echo "NON_ANCORA_ALLINEATO: completare genera_e_misura con il comando di docs/benchmarking.md" >&2
  return 3
}

echo "== prova: modello=$MODELLO tetto=$RAM cartella=$RUNDIR"
svuota_cache

# Corsa sotto gruppo di controllo con tetto di memoria che conta anche la cache dei file.
set +e
systemd-run --user --scope -p "MemoryMax=$RAM" -p "MemorySwapMax=0" --unit "$SCOPE" \
  bash -c "$(declare -f genera_e_misura); COLI_DIR='$COLI_DIR' RUNDIR='$RUNDIR' PROMPT_PROVA='$PROMPT_PROVA' TOKEN_DA_GENERARE='$TOKEN_DA_GENERARE' genera_e_misura" >"$TMP_OUT" 2>&1
ESITO=$?
set -e

# Memoria massima dal gruppo di controllo, se disponibile.
PICCO="n/d"
PEAKFILE="/sys/fs/cgroup/user.slice/$(systemctl --user show -p ControlGroup --value "$SCOPE.scope" 2>/dev/null | sed 's#.*/##')/memory.peak"
[ -r "$PEAKFILE" ] && PICCO="$(cat "$PEAKFILE" 2>/dev/null || echo n/d)"

TOKS="$(grep -oE '[0-9]+([.][0-9]+)? tok/s' "$TMP_OUT" | tail -1 || true)"
[ -z "$TOKS" ] && TOKS="n/d"

HW="$(nproc)cpu/$(free -g | awk '/Mem:/{print $2"GB"}')"
RIGA="$(date -Is)\t$MODELLO\t$RAM\t$TOKS\tpicco=$PICCO\thw=$HW\tesito=$ESITO"
printf '%b\n' "$RIGA" | tee -a "$MISURE/$MODELLO.tsv"

if [ "$ESITO" != "0" ]; then
  echo "corsa non riuscita (esito $ESITO). Ultime righe:" >&2
  tail -5 "$TMP_OUT" >&2
  exit "$ESITO"
fi
