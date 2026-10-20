#!/usr/bin/env python3
"""Le schede dei pacchetti che descrivono un repository altrui, e quando quel repository cambia.

Perché esiste. Alcuni pacchetti del template descrivono il contenuto di un repository
GitHub di qualcun altro: quali skill contiene, quali conviene prendere, quante sono. Il
2026-10-20 la scheda di `matt-pocock-skills` consigliava ancora `resolving-merge-conflicts`,
che l'autore aveva tolto il giorno prima, e diceva trentasette skill dove ce n'erano
trentuno; lo si è scoperto solo perché qualcuno ha riscaricato il repository per un'altra
ragione. Una scheda vecchia ha lo stesso aspetto di una aggiornata, quindi il controllo
non può affidarsi al ricordo: il proprietario ha chiesto che giri a ogni apertura di
sessione del template.

Il registro è `.claude/templates/fonti-a-monte.json`: una voce per repository sorvegliato,
con la cartella interna che la scheda descrive e l'ultimo commit di quella cartella che
qualcuno ha confrontato con la scheda. Si sorvegliano solo i repository di cui una scheda
descrive il contenuto; quelli soltanto citati in un elenco non diventano falsi quando
cambiano, e sorvegliarli produrrebbe avvisi che insegnano a ignorare il controllo.

    python .claude/templates/tools/fonti-a-monte.py controlla      # a inizio sessione, nel template
    python .claude/templates/tools/fonti-a-monte.py segna mattpocock/skills
    python .claude/templates/tools/fonti-a-monte.py --autotest

`controlla` chiede a GitHub l'ultimo commit che ha toccato la cartella, senza scaricare
niente, e tace sui repository invariati. Per quelli cambiati dice quanti commit, da quando
e dove leggere la differenza. Esce con 0 anche quando trova cambiamenti o non raggiunge la
rete, salvo `--rigoroso`: il suo compito è far aggiornare una scheda, non fermare il lavoro.
`segna` si lancia dopo aver aggiornato la scheda, e registra come verificato il commit di
adesso. Le richieste vanno all'API pubblica di GitHub, che senza credenziali ne concede
sessanta l'ora; se `GH_TOKEN` o `GITHUB_TOKEN` sono impostate le usa.
"""

from __future__ import annotations

import argparse
import datetime as dt
import json
import os
import sys
import tempfile
import urllib.error
import urllib.parse
import urllib.request
from pathlib import Path

REGISTRO = Path(".claude") / "templates" / "fonti-a-monte.json"
PAGINA = 30


def leggi_registro(radice: Path) -> list:
    f = radice / REGISTRO
    if not f.exists():
        return []
    voci = json.loads(f.read_text(encoding="utf-8"))
    for v in voci:
        for campo in ("repo", "pacchetto", "scheda"):
            if not v.get(campo):
                raise ValueError("voce senza %s nel registro: %r" % (campo, v))
    return voci


def scrivi_registro(radice: Path, voci: list) -> None:
    f = radice / REGISTRO
    f.write_text(json.dumps(voci, ensure_ascii=False, indent=2) + "\n", encoding="utf-8", newline="\n")


def commit_github(repo: str, cartella: str, ramo: str) -> list:
    """Gli ultimi commit che hanno toccato la cartella, dal più recente: [(sha, data)]."""
    q = {"per_page": str(PAGINA)}
    if cartella:
        q["path"] = cartella
    if ramo:
        q["sha"] = ramo
    url = "https://api.github.com/repos/%s/commits?%s" % (repo, urllib.parse.urlencode(q))
    req = urllib.request.Request(url, headers={"Accept": "application/vnd.github+json", "User-Agent": "fonti-a-monte"})
    token = os.environ.get("GH_TOKEN") or os.environ.get("GITHUB_TOKEN")
    if token:
        req.add_header("Authorization", "Bearer " + token)
    with urllib.request.urlopen(req, timeout=20) as r:
        dati = json.load(r)
    return [(c["sha"], c["commit"]["committer"]["date"][:10]) for c in dati]


def esamina(voce: dict, leggi=commit_github) -> dict:
    """Lo stato di una voce: invariata, cambiata, mai verificata o non raggiunta."""
    try:
        commit = leggi(voce["repo"], voce.get("cartella", ""), voce.get("ramo", ""))
    except (urllib.error.URLError, OSError, ValueError, KeyError) as e:
        return {"stato": "non-raggiunta", "errore": str(e)}
    if not commit:
        return {"stato": "non-raggiunta", "errore": "nessun commit per quella cartella: è stata spostata o rinominata?"}
    ultimo, data = commit[0]
    noto = voce.get("verificato", "")
    if not noto:
        return {"stato": "mai-verificata", "ultimo": ultimo, "data": data}
    if ultimo == noto:
        return {"stato": "invariata"}
    shas = [s for s, _ in commit]
    nuovi = shas.index(noto) if noto in shas else None
    return {"stato": "cambiata", "ultimo": ultimo, "data": data, "nuovi": nuovi}


def cmd_controlla(radice: Path, rigoroso: bool = False, leggi=commit_github) -> int:
    voci = leggi_registro(radice)
    cambiate = 0
    for v in voci:
        e = esamina(v, leggi)
        dove = v["repo"] + ("/" + v["cartella"] if v.get("cartella") else "")
        if e["stato"] == "invariata":
            continue
        if e["stato"] == "non-raggiunta":
            print("   ?  %s (%s): non raggiunto, %s" % (v["pacchetto"], dove, e["errore"]))
            continue
        cambiate += 1
        if e["stato"] == "mai-verificata":
            print("   !  %s (%s): mai confrontata con la scheda; ultimo commit %s del %s" % (v["pacchetto"], dove, e["ultimo"][:7], e["data"]))
        else:
            quanti = "%d commit" % e["nuovi"] if e["nuovi"] is not None else "più di %d commit" % (PAGINA - 1)
            print("   !  %s (%s): %s dal %s, ultimo del %s" % (v["pacchetto"], dove, quanti, v.get("data", "?"), e["data"]))
            print("      differenza: https://github.com/%s/compare/%s...%s" % (v["repo"], v["verificato"][:12], e["ultimo"][:12]))
        print("      scheda da rileggere: %s; poi fonti-a-monte.py segna %s" % (v["scheda"], v["repo"]))
    print("fonti a monte: %d cambiate su %d sorvegliate" % (cambiate, len(voci)))
    return 1 if (rigoroso and cambiate) else 0


def cmd_segna(radice: Path, repo: str, leggi=commit_github, oggi: str = "") -> str:
    voci = leggi_registro(radice)
    trovate = [v for v in voci if v["repo"] == repo]
    if not trovate:
        raise SystemExit("repository non sorvegliato: %s" % repo)
    for v in trovate:
        commit = leggi(v["repo"], v.get("cartella", ""), v.get("ramo", ""))
        if not commit:
            raise SystemExit("nessun commit per %s: non segno niente" % repo)
        v["verificato"] = commit[0][0]
        v["data"] = oggi or dt.date.today().isoformat()
    scrivi_registro(radice, voci)
    return trovate[0]["verificato"]


# --------------------------------------------------------------------------- prove

def autotest() -> int:
    import contextlib
    import io

    casi = rossi = 0

    def caso(nome: str, ok: bool) -> None:
        nonlocal casi, rossi
        casi += 1
        rossi += 0 if ok else 1
        print(("ok   " if ok else "ROSSO ") + nome)

    storia = {"a/uno": [("c3", "2026-10-20"), ("c2", "2026-10-19"), ("c1", "2026-10-18")],
              "b/due": [("x1", "2026-10-01")]}

    def finta(repo, cartella, ramo):
        if repo == "rete/assente":
            raise urllib.error.URLError("rete assente")
        return storia.get(repo, [])

    def esegui(radice, rigoroso=False):
        buf = io.StringIO()
        with contextlib.redirect_stdout(buf):
            rc = cmd_controlla(radice, rigoroso, finta)
        return rc, buf.getvalue()

    with tempfile.TemporaryDirectory() as d:
        r = Path(d)
        (r / REGISTRO).parent.mkdir(parents=True)
        caso("senza registro non c'è niente da sorvegliare", esegui(r)[0] == 0)
        scrivi_registro(r, [
            {"repo": "a/uno", "cartella": "skills", "pacchetto": "pa", "scheda": "pa/README.md", "verificato": "c1", "data": "2026-10-18"},
            {"repo": "b/due", "pacchetto": "pb", "scheda": "pb/README.md", "verificato": "x1", "data": "2026-10-01"},
        ])
        rc, out = esegui(r)
        caso("un repository cambiato si segnala con il numero di commit", "pa (a/uno/skills): 2 commit" in out)
        caso("la differenza si legge dal commit verificato all'ultimo", "compare/c1...c3" in out)
        caso("un repository invariato tace", "pb" not in out)
        caso("il controllo avvisa ma non blocca", rc == 0)
        caso("con --rigoroso un cambiamento blocca", esegui(r, True)[0] == 1)
        storia["a/uno"] = [("c%d" % i, "2026-10-20") for i in range(40, 1, -1)]
        caso("oltre una pagina di commit si dice che sono di più", "più di 29 commit" in esegui(r)[1])
        cmd_segna(r, "a/uno", finta, "2026-10-21")
        v = [x for x in leggi_registro(r) if x["repo"] == "a/uno"][0]
        caso("segna registra l'ultimo commit e la data", (v["verificato"], v["data"]) == ("c40", "2026-10-21"))
        caso("dopo segna il repository tace", "pa" not in esegui(r)[1])
        scrivi_registro(r, leggi_registro(r) + [
            {"repo": "rete/assente", "pacchetto": "pr", "scheda": "x", "verificato": "z"},
            {"repo": "c/nuovo", "pacchetto": "pn", "scheda": "y"},
        ])
        storia["c/nuovo"] = [("n1", "2026-10-20")]
        rc, out = esegui(r)
        caso("una rete assente si dice e non blocca", "pr (rete/assente): non raggiunto" in out and rc == 0)
        caso("una voce mai verificata si segnala come cambiata", "pn (c/nuovo): mai confrontata" in out and "1 cambiate su 4" in out)
        storia["c/nuovo"] = []
        caso("una cartella senza commit si segnala come non raggiunta", "pn (c/nuovo): non raggiunto" in esegui(r)[1])
        scrivi_registro(r, [{"repo": "a/uno", "scheda": "x"}])
        try:
            leggi_registro(r)
            ok = False
        except ValueError:
            ok = True
        caso("una voce senza pacchetto è un errore del registro", ok)
    print("\n%d casi superati su %d" % (casi - rossi, casi))
    return 1 if rossi else 0


def main(argv=None) -> int:
    try:
        sys.stdout.reconfigure(encoding="utf-8")
    except (AttributeError, ValueError):
        pass
    p = argparse.ArgumentParser(description="Le schede dei pacchetti che descrivono un repository altrui.")
    p.add_argument("--autotest", action="store_true")
    p.add_argument("--radice", default=".", help="radice del template")
    sub = p.add_subparsers(dest="comando")
    pc = sub.add_parser("controlla", help="i repository sorvegliati cambiati dall'ultima verifica")
    pc.add_argument("--rigoroso", action="store_true")
    ps = sub.add_parser("segna", help="registra come verificato il commit di adesso, dopo aver aggiornato la scheda")
    ps.add_argument("repo")
    a = p.parse_args(argv)
    if a.autotest:
        return autotest()
    radice = Path(a.radice)
    if a.comando == "controlla":
        return cmd_controlla(radice, a.rigoroso)
    if a.comando == "segna":
        print("verificato %s a %s" % (a.repo, cmd_segna(radice, a.repo)[:12]))
        return 0
    p.print_help()
    return 2


if __name__ == "__main__":
    sys.exit(main())
