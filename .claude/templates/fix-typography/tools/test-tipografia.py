#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Prova che i tre strumenti tipografici non riscrivano gli identificatori LaTeX.

Perché questa prova esiste, e perché sta in un file a sé
--------------------------------------------------------
Il 2026-08-27 `fix-missing-accents.py` ha accentato il nome di un'etichetta, cioè la
parola integrità privata del proprio accento dentro `\\label` e `\\ref`, trattando come
prosa ciò che è un identificatore. La parola nuda non compare in questo commento
deliberatamente: se comparisse, lo strumento riconoscerebbe questo file come da
correggere. Il documento ha continuato a compilare per una coincidenza, perché
l'etichetta e i suoi riferimenti sono stati riscritti nella medesima passata; un solo
riferimento rimasto indietro avrebbe prodotto due punti di domanda nel PDF senza che
nulla lo segnalasse. È esattamente la classe di errore silenzioso contro cui l'intero
progetto è costruito, prodotta da uno strumento del progetto.

La prova sta in un file separato invece che negli autotest interni dei tre strumenti per
una ragione di livello: il difetto non viveva nelle funzioni di conversione, che sono ciò
che quegli autotest coprono, ma nella funzione che decide se una porzione di testo sia
prosa. Provarlo richiede quindi di far girare la catena completa su un file vero, con la
sua estensione, ed è un tipo di prova che sporca il filesystem e non appartiene a un
autotest che deve restare istantaneo e puro.

Che cosa verifica
-----------------
Su un file `.tex` che contiene sia identificatori sia prosa, ciascuno dei tre strumenti
deve lasciare intatti gli identificatori e correggere la prosa. La prova è discriminante
per costruzione: la prosa accanto contiene una forma che ciascuno strumento converte, per
cui un esito in cui nulla cambia non è un successo ma il segnale che lo strumento non ha
girato affatto.

Uso
---
    python tools/test-tipografia.py
"""

import importlib.util
import os
import sys
import tempfile

BS = chr(92)
NL = chr(10)
APO = chr(39)
ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

# Le forme di prova si compongono per concatenazione invece di essere scritte per intero,
# ed è una precauzione necessaria e non un vezzo: se comparissero come parole intere nel
# sorgente, i tre strumenti riconoscerebbero questo file come da correggere e riscriverebbero
# i propri dati di prova alla prima passata sul repository. È il medesimo accorgimento che
# gli autotest interni dei tre strumenti già adottano, e la ragione per cui il trattino em
# della prosa di prova è indicato per codepoint anziché scritto.
_INTEGRITA = "integrit" + "a"
_IDENTITA = "identit" + "a"
_QUALITA = "qualit" + "a"
_EM = chr(0x2014)

# Gli identificatori che nessuno strumento deve toccare. Sono scelti perché ciascuno
# contiene una forma che uno dei tre strumenti riscriverebbe se li trattasse come prosa:
# le due parole prive di accento per i due strumenti degli accenti, e i trattini dei nomi
# di file per quello dei trattini.
IDENTIFICATORI = (
    BS + "ref{cap:" + _INTEGRITA + "}",
    BS + "label{cap:" + _IDENTITA + "}",
    BS + "input{capitoli/06-strutture-gen1}",
    BS + "cite{pokered,pokecrystal}",
    BS + "includegraphics[width=38mm]{figure/squirtle-sprite.png}",
)

# La prosa accanto, con una forma per ciascuno strumento: un accento mancante, un accento
# scritto con l'apostrofo, e un trattino lungo.
PROSA_PRIMA = (
    "La " + _INTEGRITA + " del dato e la sua " + _QUALITA + APO + " contano, "
    "e il trattino " + _EM + " questo " + _EM + " va normalizzato."
)
# Le forme attese sono le stesse parole con l'accento al posto della vocale finale, non con
# l'accento aggiunto dopo di essa: la vocale va sostituita, non affiancata.
_ACC = chr(0xE0)
PROSA_ATTESA_FRAMMENTI = (_INTEGRITA[:-1] + _ACC, _QUALITA[:-1] + _ACC, " - questo - ")

STRUMENTI = ("fix-accents.py", "fix-missing-accents.py", "fix-dashes.py")


def carica(nome):
    """Importa uno strumento come modulo, senza eseguirne il main."""
    percorso = os.path.join(ROOT, "tools", nome)
    spec = importlib.util.spec_from_file_location(nome.replace("-", "_")[:-3], percorso)
    modulo = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(modulo)
    return modulo


def argomenti_accessori(modulo):
    """Gli argomenti che `elabora` vuole oltre al percorso, per questo strumento.

    Le tre firme sono diverse, e invece di scriverle a mano si contano i parametri: così
    la prova non si rompe se una firma cambia, e se cambia in modo incompatibile lo dice.
    """
    import inspect
    parametri = list(inspect.signature(modulo.elabora).parameters)
    accessori = parametri[1:]
    for nome in accessori:
        if nome not in ("fatte", "viste", "statistiche", "residui", "ambigui", "conteggio"):
            raise AssertionError(
                "parametro non riconosciuto in elabora: %s. La prova va aggiornata." % nome)
    return [{} for _ in accessori]


def prova_strumento(nome):
    modulo = carica(nome)
    testo = NL.join(IDENTIFICATORI) + NL + PROSA_PRIMA + NL

    # Il file di prova sta dentro il repository perché gli strumenti calcolano un percorso
    # relativo alla radice, e su Windows un percorso su un altro volume non è relativizzabile.
    cartella = os.path.join(ROOT, "_notes", "tmp")
    os.makedirs(cartella, exist_ok=True)
    handle, percorso = tempfile.mkstemp(suffix=".tex", dir=cartella)
    with os.fdopen(handle, "wb") as f:
        f.write(testo.encode("utf-8"))

    problemi = []
    try:
        cambiato, dati = modulo.elabora(percorso, *argomenti_accessori(modulo))
        dopo = dati.decode("utf-8") if cambiato else testo
        for identificatore in IDENTIFICATORI:
            if identificatore not in dopo:
                problemi.append("ha riscritto %s" % identificatore)
        if not cambiato:
            problemi.append("non ha cambiato nulla: la prosa di prova contiene una forma "
                            "che questo strumento deve convertire, quindi non ha girato")
    finally:
        os.unlink(percorso)
    return problemi


def prova_front_matter(nome):
    """Il front matter di un file Markdown è metadato: non va accentato.

    È lo stesso difetto degli identificatori LaTeX su un altro linguaggio, e il danno è
    peggiore perché silenzioso in modo diverso: un tag accentato non rompe nulla che
    compili, semplicemente non si unisce più agli altri in un indice o in un grafo.
    """
    modulo = carica(nome)
    if not hasattr(modulo, "converti_markdown") and not hasattr(modulo, "segmenta_markdown"):
        return []  # fix-dashes non distingue il front matter e non ne ha bisogno

    testo = NL.join((
        "---",
        "tags: [" + _INTEGRITA + ", " + _QUALITA + "]",
        "up: \"[[06-" + _IDENTITA + "-pokemon]]\"",
        "---",
        "",
        "La " + _INTEGRITA + " e la " + _QUALITA + APO + " contano.",
        "",
    ))
    cartella = os.path.join(ROOT, "_notes", "tmp")
    os.makedirs(cartella, exist_ok=True)
    handle, percorso = tempfile.mkstemp(suffix=".md", dir=cartella)
    with os.fdopen(handle, "wb") as f:
        f.write(testo.encode("utf-8"))

    problemi = []
    try:
        cambiato, dati = modulo.elabora(percorso, *argomenti_accessori(modulo))
        dopo = dati.decode("utf-8") if cambiato else testo
        testa = dopo.split(NL + "---" + NL)[0]
        for atteso in (_INTEGRITA, _QUALITA, _IDENTITA):
            if atteso not in testa:
                problemi.append("ha riscritto %r nel front matter" % atteso)
    finally:
        os.unlink(percorso)
    return problemi


# Il difetto della doppia correzione, trovato il 2026-09-09 su file già corrotti.
# La forma con l'apostrofo appartiene a `fix-accents.py`; se anche `fix-missing-accents.py`
# la tocca, il risultato è una vocale accentata seguita da apostrofo, che in italiano non
# esiste e che nessuno dei due sapeva più riconoscere. La prova è discriminante nei due
# versi: verifica che il primo strumento non tocchi quella forma, e che il secondo ripari
# il residuo se lo trova già scritto. I frammenti si costruiscono per concatenazione,
# perché scritti per intero verrebbero corretti dagli strumenti alla prima passata su
# questo stesso file, che è la trappola già pagata quattro volte in questo progetto.
def prova_residuo_apostrofo():
    AP = chr(39)
    E_ACUTA = chr(0x00E9)
    A_GRAVE = chr(0x00E0)
    prima = "Serve perch" + "e" + AP + " conta, ed è gi" + "a" + AP + " scritto."
    residuo = "Serve perch" + E_ACUTA + AP + " conta, ed è gi" + A_GRAVE + AP + " scritto."
    atteso = "perch" + E_ACUTA
    falliti = 0
    cartella = os.path.join(ROOT, "_notes", "tmp")
    os.makedirs(cartella, exist_ok=True)

    def gira(nome, contenuto):
        handle, percorso = tempfile.mkstemp(suffix=".md", dir=cartella)
        with os.fdopen(handle, "wb") as f:
            f.write((contenuto + NL).encode("utf-8"))
        try:
            modulo = carica(nome)
            cambiato, dati = modulo.elabora(percorso, *argomenti_accessori(modulo))
            if cambiato:
                with open(percorso, "wb") as f:
                    f.write(dati)
            return open(percorso, "rb").read().decode("utf-8")
        finally:
            os.unlink(percorso)

    dopo = gira("fix-missing-accents.py", prima)
    if dopo.strip() != prima:
        print("  FALLITA  residuo apostrofo        fix-missing-accents tocca la forma "
              "con apostrofo, che non è sua")
        falliti += 1

    dopo = gira("fix-accents.py", residuo)
    if AP in dopo or atteso not in dopo:
        print("  FALLITA  residuo apostrofo        fix-accents non ripara la vocale "
              "accentata seguita da apostrofo")
        falliti += 1

    dopo = gira("fix-accents.py", prima)
    if atteso not in dopo:
        print("  FALLITA  residuo apostrofo        fix-accents non converte più la "
              "forma con apostrofo")
        falliti += 1

    if falliti == 0:
        print("  ok       residuo apostrofo        i due strumenti non si sovrappongono")
    return falliti


# Lo stesso difetto della doppia correzione, ritrovato il 2026-09-15 in un punto che la
# prima riparazione non aveva raggiunto. Il guardiano di apostrofo era stato messo nella
# funzione che costruisce le espressioni delle parole singole, ma le forme composte con
# elisione, quelle della tabella COMPOSTE, stanno in una tabella propria che non passa da
# quella funzione, e il confine di parola finale e' soddisfatto anche da un apostrofo:
# una forma scritta con l'apostrofo veniva quindi accentata lasciando l'apostrofo
# attaccato. Le forme di prova si compongono per concatenazione come tutte le altre di
# questo file, perche' scritte per intero verrebbero corrette alla prima passata su
# questo stesso sorgente. La prova e' discriminante nei due versi, perche' un guardiano
# troppo largo spegnerebbe la conversione legittima invece di limitarla.
def prova_composte_apostrofo():
    AP = chr(39)
    E_GRAVE = chr(0x00E8)
    da_convertire = "Qui c" + AP + "e un problema e dov" + AP + "e finito."
    con_apostrofo = "Qui c" + AP + "e" + AP + " un problema e dov" + AP + "e" + AP + " finito."
    atteso = "c" + AP + E_GRAVE
    falliti = 0
    cartella = os.path.join(ROOT, "_notes", "tmp")
    os.makedirs(cartella, exist_ok=True)

    def gira(nome, contenuto):
        handle, percorso = tempfile.mkstemp(suffix=".md", dir=cartella)
        with os.fdopen(handle, "wb") as f:
            f.write((contenuto + NL).encode("utf-8"))
        try:
            modulo = carica(nome)
            cambiato, dati = modulo.elabora(percorso, *argomenti_accessori(modulo))
            if cambiato:
                with open(percorso, "wb") as f:
                    f.write(dati)
            return open(percorso, "rb").read().decode("utf-8")
        finally:
            os.unlink(percorso)

    dopo = gira("fix-missing-accents.py", con_apostrofo)
    if dopo.strip() != con_apostrofo:
        print("  FALLITA  composte con apostrofo   fix-missing-accents tocca la forma "
              "composta scritta con l" + AP + "apostrofo")
        falliti += 1

    dopo = gira("fix-missing-accents.py", da_convertire)
    if atteso not in dopo:
        print("  FALLITA  composte con apostrofo   fix-missing-accents non converte "
              "la forma composta legittima")
        falliti += 1

    dopo = gira("fix-accents.py", con_apostrofo)
    if atteso not in dopo or AP + " " in dopo.replace("l" + AP + "apostrofo", ""):
        print("  FALLITA  composte con apostrofo   fix-accents non converte la forma "
              "composta scritta con l" + AP + "apostrofo")
        falliti += 1

    if falliti == 0:
        print("  ok       composte con apostrofo   il guardiano limita senza spegnere")
    return falliti


def main():
    falliti = 0
    for nome in STRUMENTI:
        problemi = prova_strumento(nome) + prova_front_matter(nome)
        if problemi:
            falliti += len(problemi)
            for p in problemi:
                print("  FALLITA  %-24s %s" % (nome, p))
        else:
            print("  ok       %-24s identificatori intatti, prosa corretta" % nome)

    # La prosa deve essere stata corretta dalla catena dei tre, non da uno solo: si
    # verifica applicandoli in sequenza al medesimo file.
    cartella = os.path.join(ROOT, "_notes", "tmp")
    os.makedirs(cartella, exist_ok=True)
    handle, percorso = tempfile.mkstemp(suffix=".tex", dir=cartella)
    with os.fdopen(handle, "wb") as f:
        f.write((NL.join(IDENTIFICATORI) + NL + PROSA_PRIMA + NL).encode("utf-8"))
    try:
        for nome in STRUMENTI:
            modulo = carica(nome)
            cambiato, dati = modulo.elabora(percorso, *argomenti_accessori(modulo))
            if cambiato:
                with open(percorso, "wb") as f:
                    f.write(dati)
        finale = open(percorso, "rb").read().decode("utf-8")
    finally:
        os.unlink(percorso)

    for frammento in PROSA_ATTESA_FRAMMENTI:
        if frammento not in finale:
            print("  FALLITA  catena dei tre           la prosa non contiene %r" % frammento)
            falliti += 1
    for identificatore in IDENTIFICATORI:
        if identificatore not in finale:
            print("  FALLITA  catena dei tre           ha riscritto %s" % identificatore)
            falliti += 1
    if falliti == 0:
        print("  ok       catena dei tre           prosa corretta, identificatori intatti")

    falliti += prova_residuo_apostrofo()
    falliti += prova_composte_apostrofo()

    print("test-tipografia: %d controlli falliti" % falliti)
    return 1 if falliti else 0


if __name__ == "__main__":
    sys.exit(main())
