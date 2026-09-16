#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Dice, alla riapertura, se fra l'ultima sessione e questa si e' perso qualcosa.

Perché esiste
-------------
La procedura di ripresa del sistema parte da `_notes/RESUME-PROMPT.md`, che l'agente aggiorna
alla fine di ogni sessione con lo stato raggiunto. Quella procedura presuppone una cosa che non
sempre è vera: che la sessione precedente sia arrivata alla fine. Una sessione che cade a metà,
per un crash, per una compattazione andata male o semplicemente perché la finestra è stata
chiusa, lascia il progetto in uno stato che il file di ripresa non descrive, e la sessione
successiva riparte da una fotografia che non sa di essere vecchia.

Il danno non è la perdita del lavoro, che sta su disco e in git. È più sottile: la sessione nuova
legge il file di ripresa, lo prende per lo stato corrente, e costruisce sopra una premessa falsa.
Nessuno se ne accorge, perché un file di ripresa vecchio ha esattamente lo stesso aspetto di uno
aggiornato.

Che cosa rende meccanica la scoperta
-------------------------------------
Una impronta. A fine sessione si registra nel file di ripresa lo stato di git in quel momento,
cioè il commit, la forma esatta dell'albero di lavoro e il momento della registrazione. Alla
riapertura si riprende quell'impronta e la si confronta con lo stato reale. Se coincidono, la
sessione precedente si è chiusa dopo aver scritto, e il file di ripresa descrive davvero il
presente. Se divergono, fra la registrazione e adesso è successo qualcosa che il file non
racconta, e questo programma dice che cosa: quali commit sono comparsi, quali file sono cambiati,
quali documenti di memoria sono rimasti indietro.

Si appoggia a git e non ai tempi di modifica dei file, che sopravvivono male a un clone, a una
copia e a un checkout, e che su una macchina con l'orologio storto mentono senza dirlo.

Che cosa non può sapere, e va detto invece di lasciarlo intuire
---------------------------------------------------------------
Non può sapere se il lavoro fatto nella sessione caduta fosse giusto: legge fatti, non giudizi.
Non può sapere se una decisione presa in chat sia stata scritta, perché una decisione non scritta
non lascia traccia su disco, ed è esattamente il buco che la regola `chat-non-e-memoria.md` esiste
per prevenire a monte invece di rilevare a valle. E non può ricostruire ciò che non è mai stato
salvato. Ciò che fa è più modesto e utile: dice dove guardare, in ordine di probabilità, quando
qualcosa non torna.

Uso
---
    python tools/verifica-ripresa.py                confronta e riporta
    python tools/verifica-ripresa.py --registra     scrive l'impronta, a fine sessione
    python tools/verifica-ripresa.py --breve        una riga di esito, per un hook
    python tools/verifica-ripresa.py --self-test

Esce con codice diverso da zero quando trova una divergenza, così che un hook di apertura
sessione possa segnalarla senza che nessuno debba leggere l'output.
"""

import argparse
import hashlib
import io
import os
import re
import subprocess
import sys
import time

if hasattr(sys.stdout, "reconfigure"):
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")

RIPRESA = os.path.join("_notes", "RESUME-PROMPT.md")
INDICE = os.path.join(".claude", "memory", "index.md")
PROGRESSO = os.path.join(".claude", "memory", "progress.md")
CONTESTO = os.path.join(".claude", "context")

APERTURA = "<!-- impronta-ripresa"
CHIUSURA = "-->"

# I documenti la cui arretratezza vale segnalare, con il perché in chiaro: non sono tutti i file
# della memoria, sono quelli che una sessione che si chiude bene tocca sempre.
SORVEGLIATI = [
    (INDICE, "lo snapshot che la procedura di ripresa legge per primo"),
    (PROGRESSO, "il work-log, dove la sessione registra che cosa ha fatto"),
]


class Errore(Exception):
    """Un guasto che l'utente deve leggere."""


def git(*argomenti, radice=None):
    """Esegue git e ritorna l'uscita, oppure solleva con il messaggio del comando."""
    try:
        p = subprocess.run(["git"] + list(argomenti), cwd=radice, capture_output=True, text=True,
                           encoding="utf-8", errors="replace")
    except FileNotFoundError:
        raise Errore("git non e' sul PATH: questo controllo legge lo stato da git e non dai "
                     "tempi di modifica dei file, che mentono dopo un clone o una copia")
    if p.returncode != 0:
        raise Errore("git " + " ".join(argomenti) + " e' fallito: " + (p.stderr or "").strip()[:200])
    return p.stdout


def impronta_corrente(radice=None, ora=None):
    """Lo stato di git adesso, nella forma che si confronta.

    L'albero di lavoro si riduce a un digest invece di essere conservato per esteso: interessa
    sapere se sia cambiato, non che cosa contenesse, e un elenco lungo dentro un file di ripresa
    lo renderebbe illeggibile. L'elenco vero si ottiene con `git status` quando serve.
    """
    commit = git("rev-parse", "HEAD", radice=radice).strip()
    stato = git("status", "--porcelain", radice=radice)
    # Il file di ripresa si esclude, ed e' la riga piu' importante di questa funzione. E' il file
    # che `--registra` scrive: contarlo significherebbe fotografare un albero che la fotografia
    # stessa sta per cambiare, e la corsa successiva troverebbe una divergenza prodotta da noi.
    # Nel sistema di progetto `_notes/` e' ignorato da git e il caso non si presenta, ma quella e'
    # una convenzione del progetto ospite: un programma corretto solo finche' una convenzione
    # altrui regge e' un programma che aspetta di sbagliare.
    nostro = RIPRESA.replace(os.sep, "/")
    righe = [r for r in stato.splitlines()
             if r.strip() and nostro not in r.replace("\\", "/")]
    digest = hashlib.sha256("\n".join(sorted(righe)).encode("utf-8")).hexdigest()[:16]
    return {
        "commit": commit,
        "albero": digest,
        "modificati": len([r for r in righe if not r.startswith("??")]),
        "non_tracciati": len([r for r in righe if r.startswith("??")]),
        "scritto": ora or time.strftime("%Y-%m-%d %H:%M"),
    }


def blocco(impronta):
    """L'impronta come commento HTML, che il rendering non mostra e md-unwrap non tocca."""
    r = [APERTURA]
    for chiave in ("commit", "albero", "modificati", "non_tracciati", "scritto"):
        r.append("%s: %s" % (chiave, impronta[chiave]))
    r.append(CHIUSURA)
    return "\n".join(r)


def leggi_impronta(testo):
    """L'impronta registrata, oppure None se non ce n'e' una."""
    i = testo.find(APERTURA)
    if i < 0:
        return None
    j = testo.find(CHIUSURA, i)
    if j < 0:
        return None
    d = {}
    for riga in testo[i + len(APERTURA):j].splitlines():
        m = re.match(r"\s*([a-z_]+):\s*(.*)$", riga)
        if m:
            d[m.group(1)] = m.group(2).strip()
    for chiave in ("commit", "albero"):
        if chiave not in d:
            return None
    for chiave in ("modificati", "non_tracciati"):
        try:
            d[chiave] = int(d.get(chiave, 0))
        except ValueError:
            d[chiave] = 0
    return d


def registra(radice=None, ora=None):
    """Scrive l'impronta nel file di ripresa, sostituendo quella precedente."""
    percorso = os.path.join(radice or ".", RIPRESA)
    if not os.path.isfile(percorso):
        raise Errore("non trovo " + RIPRESA + ": il file di ripresa si istanzia dal template "
                     "omonimo, e senza di esso non c'e' dove registrare l'impronta")
    testo = io.open(percorso, encoding="utf-8", errors="replace").read()
    nuovo = blocco(impronta_corrente(radice=radice, ora=ora))
    i = testo.find(APERTURA)
    if i >= 0:
        j = testo.find(CHIUSURA, i)
        testo = testo[:i] + nuovo + testo[j + len(CHIUSURA):]
    else:
        # In coda e non in testa: il file di ripresa si legge dall'alto, e un blocco tecnico
        # in prima riga sposterebbe in basso la cosa per cui il file esiste.
        testo = testo.rstrip("\n") + "\n\n" + nuovo + "\n"
    io.open(percorso, "w", encoding="utf-8", newline="\n").write(testo)
    return percorso


def commit_dichiarato(percorso):
    """L'hash che un documento di memoria dichiara come proprio riferimento, se lo dichiara."""
    if not os.path.isfile(percorso):
        return None
    testo = io.open(percorso, encoding="utf-8", errors="replace").read()
    m = re.search(r"(?:Commit di riferimento|last-verified-commit|generated-from-commit)\s*:?\s*"
                  r"([0-9a-f]{7,40}|PENDING-FIRST-COMMIT)", testo)
    return m.group(1) if m else None


def schede_indietro(radice=None):
    """Le schede di contesto il cui commit di verifica non e' fra gli antenati di HEAD.

    Non duplica `sync-context`, che confronta i file coperti e propone il delta: qui interessa il
    solo fatto che una scheda sia ancorata a un commit che non c'e' piu', cioe' il sintomo di una
    riscrittura della storia o di una scheda copiata da un altro ramo.
    """
    cartella = os.path.join(radice or ".", CONTESTO)
    if not os.path.isdir(cartella):
        return []
    fuori = []
    for nome in sorted(os.listdir(cartella)):
        if not nome.endswith(".md"):
            continue
        h = commit_dichiarato(os.path.join(cartella, nome))
        if not h or h == "PENDING-FIRST-COMMIT":
            continue
        try:
            git("cat-file", "-e", h + "^{commit}", radice=radice)
        except Errore:
            fuori.append((nome, h))
    return fuori


def confronta(radice=None):
    """Il confronto completo. Ritorna (divergenze, note), entrambe liste di stringhe."""
    divergenze = []
    note = []

    percorso = os.path.join(radice or ".", RIPRESA)
    adesso = impronta_corrente(radice=radice)

    if not os.path.isfile(percorso):
        divergenze.append(
            "non esiste " + RIPRESA + ": la procedura di ripresa non ha da dove partire. Si "
            "istanzia dal template omonimo, e si registra l'impronta a fine sessione.")
        return divergenze, note

    vecchia = leggi_impronta(io.open(percorso, encoding="utf-8", errors="replace").read())
    if vecchia is None:
        note.append(
            "il file di ripresa non porta ancora un'impronta: questa e' la prima corsa, e finche' "
            "non se ne registra una non c'e' niente da confrontare. Si registra a fine sessione "
            "con --registra.")
    else:
        if vecchia["commit"] != adesso["commit"]:
            try:
                nuovi = git("log", "--oneline", "--no-decorate",
                            vecchia["commit"] + ".." + adesso["commit"], radice=radice).strip()
            except Errore:
                nuovi = ""
            if nuovi:
                divergenze.append(
                    "sono comparsi commit dopo l'ultima registrazione, quindi la sessione che li "
                    "ha prodotti non ha aggiornato il file di ripresa:\n    "
                    + "\n    ".join(nuovi.splitlines()))
            else:
                divergenze.append(
                    "il commit registrato (" + vecchia["commit"][:9] + ") non e' un antenato di "
                    "HEAD (" + adesso["commit"][:9] + "): il ramo e' cambiato, oppure la storia e' "
                    "stata riscritta dopo l'ultima registrazione.")
        if vecchia["albero"] != adesso["albero"]:
            divergenze.append(
                "l'albero di lavoro non e' quello registrato: allora %d modificati e %d non "
                "tracciati, adesso %d e %d. Il dettaglio si vede con `git status --short`."
                % (vecchia.get("modificati", 0), vecchia.get("non_tracciati", 0),
                   adesso["modificati"], adesso["non_tracciati"]))
        if vecchia.get("scritto"):
            note.append("ultima registrazione: " + str(vecchia["scritto"]))

    # I documenti di memoria che una sessione chiusa bene avrebbe toccato.
    for documento, ruolo in SORVEGLIATI:
        p = os.path.join(radice or ".", documento)
        if not os.path.isfile(p):
            note.append("manca " + documento + ", che e' " + ruolo)
            continue
        dichiarato = commit_dichiarato(p)
        if dichiarato and dichiarato != "PENDING-FIRST-COMMIT" \
                and not adesso["commit"].startswith(dichiarato):
            divergenze.append(
                documento + " dichiara il commit " + dichiarato + " mentre HEAD e' "
                + adesso["commit"][:9] + ": " + ruolo + ", quindi lo stato che la sessione nuova "
                "legge per primo e' piu' vecchio del codice.")

    for nome, h in schede_indietro(radice=radice):
        divergenze.append(
            "la scheda context/" + nome + " e' ancorata al commit " + h + ", che in questo "
            "repository non esiste: viene da un altro ramo, o da una storia riscritta.")

    if adesso["modificati"] or adesso["non_tracciati"]:
        note.append("nell'albero di lavoro ci sono %d file modificati e %d non tracciati: se non "
                    "li ha lasciati di proposito l'ultima sessione, sono il lavoro che quella "
                    "sessione stava facendo quando e' caduta."
                    % (adesso["modificati"], adesso["non_tracciati"]))

    return divergenze, note


# ------------------------------------------------------------------------------------------
# Le prove, contro repository veri creati al volo e poi cancellati. Non usano la rete e non
# toccano il repository ospite, perche' una prova che scrive dove vive il codice e' una prova
# che prima o poi cancella qualcosa.
# ------------------------------------------------------------------------------------------

def self_test():
    import shutil
    import tempfile
    esiti = []

    def prova(nome, condizione, dettaglio=""):
        esiti.append((nome, bool(condizione), dettaglio))

    def repo():
        d = tempfile.mkdtemp(prefix="verifica-ripresa-")
        git("init", "-q", radice=d)
        git("config", "user.email", "prova@esempio.invalid", radice=d)
        git("config", "user.name", "Prova", radice=d)
        os.makedirs(os.path.join(d, "_notes"))
        os.makedirs(os.path.join(d, ".claude", "memory"))
        os.makedirs(os.path.join(d, ".claude", "context"))
        io.open(os.path.join(d, RIPRESA), "w", encoding="utf-8").write("# Resume prompt\n")
        io.open(os.path.join(d, "codice.txt"), "w", encoding="utf-8").write("uno\n")
        git("add", "-A", radice=d)
        git("commit", "-q", "-m", "primo", radice=d)
        return d

    tmp = None
    try:
        # Sessione chiusa bene: si registra e subito dopo non diverge niente.
        tmp = repo()
        registra(radice=tmp)
        div, note = confronta(radice=tmp)
        prova("dopo una registrazione pulita non diverge niente", div == [], str(div))
        testo = io.open(os.path.join(tmp, RIPRESA), encoding="utf-8").read()
        prova("l'impronta finisce nel file di ripresa", APERTURA in testo, "")
        prova("l'impronta sta in coda e non in testa",
              testo.index("# Resume prompt") < testo.index(APERTURA), "")
        prova("l'impronta e' un commento, quindi non si vede nel rendering",
              testo.strip().endswith(CHIUSURA), "")

        # Il difetto che questa prova pianta: registrare scrive nel file di ripresa, e se quel
        # file entra nell'impronta la registrazione invalida se stessa. Vale anche dove il file
        # sia tracciato, cioe' dove la convenzione del progetto ospite non regga.
        git("add", "-A", radice=tmp)
        git("commit", "-q", "-m", "il file di ripresa entra in git", radice=tmp)
        registra(radice=tmp)
        div, _n = confronta(radice=tmp)
        prova("negativo: registrare non invalida se stesso nemmeno con il file di ripresa tracciato",
              div == [], str(div))

        # Il caso che il programma esiste per cogliere: un commit dopo la registrazione.
        io.open(os.path.join(tmp, "codice.txt"), "a", encoding="utf-8").write("due\n")
        git("add", "-A", radice=tmp)
        git("commit", "-q", "-m", "lavoro della sessione caduta", radice=tmp)
        div, note = confronta(radice=tmp)
        prova("un commit dopo la registrazione si vede", any("commit dopo" in d for d in div),
              str(div))
        prova("il commit perduto si nomina, non si conta soltanto",
              any("lavoro della sessione caduta" in d for d in div), str(div))

        # Un file lasciato a meta' nell'albero di lavoro.
        registra(radice=tmp)
        io.open(os.path.join(tmp, "a-meta.txt"), "w", encoding="utf-8").write("interrotto\n")
        div, note = confronta(radice=tmp)
        prova("un file comparso dopo la registrazione si vede",
              any("albero di lavoro non e' quello registrato" in d for d in div), str(div))
        prova("negativo: non pretende di sapere che cosa contenga",
              not any("interrotto" in d for d in div), str(div))

        # Lo snapshot della memoria rimasto indietro.
        io.open(os.path.join(tmp, INDICE), "w", encoding="utf-8").write(
            "Commit di riferimento: 0123456\n")
        div, note = confronta(radice=tmp)
        prova("uno snapshot di memoria arretrato si segnala",
              any("index.md dichiara il commit" in d for d in div), str(div))

        # Una scheda ancorata a un commit che non esiste.
        io.open(os.path.join(tmp, CONTESTO, "STACK.md"), "w", encoding="utf-8").write(
            "---\nlast-verified-commit: deadbee\n---\n")
        div, note = confronta(radice=tmp)
        prova("una scheda ancorata a un commit inesistente si segnala",
              any("STACK.md" in d and "non esiste" in d for d in div), str(div))

        # E il caso in cui il segnaposto del greenfield non va scambiato per un difetto.
        io.open(os.path.join(tmp, CONTESTO, "STACK.md"), "w", encoding="utf-8").write(
            "---\nlast-verified-commit: PENDING-FIRST-COMMIT\n---\n")
        div, note = confronta(radice=tmp)
        prova("negativo: il segnaposto del greenfield non e' una divergenza",
              not any("STACK.md" in d for d in div), str(div))

        shutil.rmtree(tmp, ignore_errors=True)

        # Un repository senza file di ripresa: lo dice invece di fallire.
        tmp = repo()
        os.remove(os.path.join(tmp, RIPRESA))
        div, note = confronta(radice=tmp)
        prova("senza file di ripresa lo dichiara come divergenza",
              any("non esiste" in d and "RESUME-PROMPT" in d for d in div), str(div))

        # Un file di ripresa senza impronta: e' la prima corsa, non un difetto.
        io.open(os.path.join(tmp, RIPRESA), "w", encoding="utf-8").write("# Resume prompt\n")
        div, note = confronta(radice=tmp)
        prova("negativo: la prima corsa non e' una divergenza", div == [], str(div))
        prova("la prima corsa lo dice fra le note",
              any("prima corsa" in n for n in note), str(note))

        # La lettura dell'impronta regge una riga sporca invece di rompersi.
        d = leggi_impronta(APERTURA + "\ncommit: abc123\nalbero: xyz\nspazzatura\n" + CHIUSURA)
        prova("l'impronta si legge anche con una riga che non le appartiene",
              d and d["commit"] == "abc123", str(d))
        prova("negativo: un'impronta senza i campi che servono non si legge a meta'",
              leggi_impronta(APERTURA + "\ncommit: abc\n" + CHIUSURA) is None, "")
    finally:
        if tmp:
            import shutil as _s
            _s.rmtree(tmp, ignore_errors=True)

    larghezza = max(len(n) for n, _, _ in esiti)
    falliti = 0
    for nome, ok, dettaglio in esiti:
        if not ok:
            falliti += 1
        print("  %s  %s%s" % (nome.ljust(larghezza), "ok" if ok else "FALLITO",
                              ("  " + dettaglio[:160]) if (dettaglio and not ok) else ""))
    print("")
    print("%d prove, %d fallite." % (len(esiti), falliti))
    return 1 if falliti else 0


def main():
    p = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    p.add_argument("--registra", action="store_true",
                   help="scrive l'impronta nel file di ripresa; si fa a fine sessione")
    p.add_argument("--breve", action="store_true", help="una riga di esito, per un hook")
    p.add_argument("--radice", help="radice del repository; per difetto la cartella corrente")
    p.add_argument("--self-test", action="store_true")
    a = p.parse_args()

    if a.self_test:
        return self_test()

    try:
        if a.registra:
            dove = registra(radice=a.radice)
            print("impronta registrata in " + dove)
            return 0

        divergenze, note = confronta(radice=a.radice)
        if a.breve:
            if divergenze:
                print("ripresa: %d divergenze fra il file di ripresa e lo stato reale" % len(divergenze))
            else:
                print("ripresa: il file di ripresa descrive lo stato corrente")
            return 1 if divergenze else 0

        if divergenze:
            print("Fra l'ultima registrazione e adesso e' successo qualcosa che il file di")
            print("ripresa non racconta. In ordine, che cosa guardare:")
            print("")
            for i, d in enumerate(divergenze, 1):
                print("  %d. %s" % (i, d))
            print("")
        else:
            print("Il file di ripresa descrive lo stato corrente: nessuna divergenza.")
            print("")
        if note:
            for n in note:
                print("  nota: " + n)
            print("")
        print("Questo controllo legge fatti di git e non giudizi: non sa se il lavoro fatto fosse")
        print("giusto, e soprattutto non sa se una decisione presa a voce sia stata scritta, che")
        print("e' il buco che la regola sulla persistenza previene a monte invece di rilevare qui.")
        return 1 if divergenze else 0
    except Errore as e:
        sys.stderr.write(str(e) + "\n")
        return 2


if __name__ == "__main__":
    sys.exit(main())
