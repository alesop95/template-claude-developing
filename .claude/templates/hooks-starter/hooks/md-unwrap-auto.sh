#!/usr/bin/env bash
# Hook PostToolUse su Write ed Edit (variante POSIX): riporta i paragrafi del file appena
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

RAW="$(cat)"
[ -z "$RAW" ] && exit 0

# Si estrae il percorso senza dipendere da un parser JSON, perche' un hook non deve portare
# dipendenze: il campo e' una stringa e la sua forma e' stabile.
PERCORSO="$(printf '%s' "$RAW" | grep -o '"file_path"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/.*:[[:space:]]*"//; s/"$//')"
[ -z "$PERCORSO" ] && exit 0

case "$PERCORSO" in
    *.md) ;;
    *) exit 0 ;;
esac
[ -f "$PERCORSO" ] || exit 0

RADICE="${CLAUDE_PROJECT_DIR:-$PWD}"
STRUMENTO="$RADICE/tools/md-unwrap.py"
[ -f "$STRUMENTO" ] || exit 0

# L'interprete si sceglie invece di assumerlo. Su una macchina con Git Bash `python3` puo'
# esistere sul PATH ed essere l'alias fittizio del Microsoft Store, che non esegue niente e non
# sbaglia: un hook che lo invocasse uscirebbe zero senza aver fatto nulla, cioe' fallirebbe in
# silenzio, che e' il modo peggiore. Si prova quale dei due risponde davvero.
PY=""
for candidato in python3 python; do
    if command -v "$candidato" >/dev/null 2>&1 && "$candidato" -c "import sys" >/dev/null 2>&1; then
        PY="$candidato"
        break
    fi
done
[ -n "$PY" ] || exit 0

# Il marcatore che esenta una cartella dalla normalizzazione lo rispetta lo strumento stesso:
# qui non si duplica quella logica, perche' due copie della stessa regola divergono.
"$PY" "$STRUMENTO" "$PERCORSO" >/dev/null 2>&1

exit 0
