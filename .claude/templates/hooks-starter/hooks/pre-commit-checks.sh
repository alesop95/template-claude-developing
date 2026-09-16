#!/usr/bin/env bash
# Hook PreToolUse su Bash (variante POSIX): quando il comando in arrivo e' un git commit,
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
# dell'utente non passano di qui, ed e' il caso normale in questo sistema: per coprirli serve
# un hook nativo di git, e il README del pacchetto spiega come. Vale quindi come rete e non
# come garanzia.
#
# Blocco = exit 2 con il motivo su stderr.

RAW="$(cat)"
printf '%s' "$RAW" | grep -qE 'git[[:space:]]+commit' || exit 0

RADICE="${CLAUDE_PROJECT_DIR:-$PWD}"
FALLITI=""

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
# Senza un interprete non si blocca un commit: un hook che ferma il lavoro perche' non
# trova python sarebbe peggio del difetto che cerca.
[ -n "$PY" ] || exit 0

# Un controllo il cui strumento non e' istanziato si salta in silenzio: un progetto puo'
# legittimamente non avere quel pacchetto, e un hook che fallisse per questo renderebbe
# impossibile committare.
esegui() {
    nome="$1"; file="$2"; shift 2
    [ -f "$RADICE/$file" ] || return 0
    if ! "$PY" "$RADICE/$file" "$@" >/dev/null 2>&1; then
        FALLITI="$FALLITI
  - $nome: rilanciare  python $file $*"
    fi
}

# Il perimetro e' la radice del progetto e non il punto: il punto si risolve sulla cartella
# corrente del processo che esegue l'hook, e le due coincidono in una sessione ordinaria ma non
# per contratto. Un controllo che girasse sulla cartella sbagliata non darebbe un errore, darebbe
# zero segnalazioni, cioe' un via libera indistinguibile da quello vero.
esegui "forma dei paragrafi Markdown" "tools/md-unwrap.py" --check --oracle require "$RADICE"
esegui "accenti"                      "tools/fix-accents.py" --check "$RADICE"
esegui "trattini"                     "tools/fix-dashes.py" --check "$RADICE"
esegui "comandi copiabili"            "tools/lint-md-commands.py" "$RADICE"
esegui "riferimenti a file"           "tools/lint-doc-references.py" --radice "$RADICE" --solo-vivi

if [ -n "$FALLITI" ]; then
    {
        echo "Controlli pre-commit falliti (hook pre-commit-checks). Il commit e' stato fermato."
        echo "$FALLITI"
        echo "Nessuno di questi produce un errore visibile se lo si ignora: e' la ragione per cui li controlla un programma."
    } >&2
    exit 2
fi

exit 0
