#!/usr/bin/env bash
# Hook SessionStart (variante POSIX): rende automatica la verifica di ripresa e chiede
# all'agente di misurare il drift, che e' il passo che un programma non puo' fare da se'.
#
# Perche' esiste, e che cosa lo distingue da session-context. Quell'hook stampa lo stato:
# branch, commit, file modificati, testa della memoria. Questo non stampa lo stato, lo
# CONFRONTA con quello che la sessione precedente aveva registrato, e la differenza e' tutta
# qui: una sessione caduta a meta' lascia un file di ripresa che descrive un passato, e un
# file di ripresa non aggiornato ha esattamente lo stesso aspetto di uno aggiornato. Nessuna
# stampa dello stato corrente rivela quella condizione: serve il confronto.
#
# Il secondo mestiere di questo hook e' meno ovvio. L'uscita di un hook SessionStart entra nel
# contesto della sessione, quindi una riga di istruzione qui dentro e' il solo modo di rendere
# automatico un passo che richiede l'agente e non un programma: la misura del drift fra schede
# e codice la fa la skill sync-context, e nessun hook puo' invocare una skill.

RADICE="${CLAUDE_PROJECT_DIR:-$PWD}"
STRUMENTO="$RADICE/tools/verifica-ripresa.py"

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

echo "=== Verifica di ripresa ==="

if [ ! -f "$STRUMENTO" ] || [ -z "$PY" ]; then
    # Il progetto non ha istanziato lo strumento: si dichiara e non si blocca niente.
    echo "tools/verifica-ripresa.py non e' istanziato in questo progetto: la verifica"
    echo "di ripresa non e' disponibile. Si istanzia dal pacchetto del template."
else
    USCITA="$("$PY" "$STRUMENTO" 2>&1)"
    ESITO=$?
    echo "$USCITA"
    if [ $ESITO -ne 0 ]; then
        echo ""
        echo "ISTRUZIONE PER L'AGENTE: sopra ci sono divergenze fra il file di ripresa e"
        echo "lo stato reale. Riportale all'utente PRIMA di qualunque altra cosa e prima"
        echo "di leggere il file di ripresa, seguendo la skill riprendi: un file lasciato"
        echo "a meta' puo' essere un lavoro da riprendere o uno da buttare, e la"
        echo "differenza non si legge dal contenuto. Non decidere: chiedi."
    fi
fi

echo ""
echo "ISTRUZIONE PER L'AGENTE: come secondo atto della sessione invoca la skill"
echo "sync-context, per misurare il drift fra le schede di .claude/context/ e il codice."
echo "Nessun hook puo' invocare una skill, quindi questo passo dipende da te. Poi leggi"
echo "le sole schede pertinenti al task, mai tutte insieme."

exit 0
