#!/usr/bin/env python3
"""Crea e verifica un vault Obsidian sopra la memoria e la documentazione di un progetto, senza copiare niente.

Perche' esiste. Il 2026-11-12 il proprietario ha chiesto che la memoria di ogni progetto possa
diventare un vault Obsidian, per leggere la documentazione e le relazioni fra i documenti, con
un insieme di plugin di base uguale a quello dei vault che usa gia'. Il sistema tiene la
memoria sotto `.claude/`, e Obsidian non mostra le cartelle il cui nome comincia con un punto:
aprire la radice del progetto come vault lascerebbe fuori proprio la memoria. Copiarla in una
cartella visibile creerebbe due verita', che e' il difetto che la regola sulla persistenza
esiste per evitare.

Che cosa fa. Crea una cartella di vault, per difetto `_vault/` nella radice del progetto, che
contiene soltanto collegamenti alle cartelle vere e la configurazione di Obsidian:

    _vault/memoria    ->  .claude/memory
    _vault/contesto   ->  .claude/context
    _vault/docs       ->  docs
    _vault/.obsidian/     plugin di base e impostazioni

Su Windows i collegamenti sono giunzioni di cartella, che non chiedono privilegi; altrove sono
collegamenti simbolici. Cio' che si scrive in Obsidian finisce nel file vero, che resta
versionato dov'e'. La cartella del vault non si versiona: e' una vista, e si ricrea con un
comando. Il comando lo dice e, con --ignora, aggiunge la riga al `.gitignore`.

I plugin di base sono tre, quelli che i vault del proprietario avevano in comune il
2026-11-12: obsidian42-brat, new-3d-graph ed embed-html. Si copiano da un vault gia' presente
sulla macchina, indicato con --da-vault o nel file `~/.config/vault-riferimento.txt`: e' una
copia locale, senza rete, di codice che il proprietario ha gia' scelto di eseguire. Dove un
vault di riferimento non c'e', il comando scrive la sola configurazione e dice quali plugin
installare da Obsidian. Un plugin e' codice che gira dentro Obsidian con i permessi
dell'utente: questo strumento non ne scarica nessuno da solo.

Uso:
    python tools/vault-progetto.py crea [--radice .] [--cartella _vault] [--da-vault <vault>] [--ignora]
    python tools/vault-progetto.py verifica [--radice .] [--cartella _vault]
    python tools/vault-progetto.py togli [--radice .] [--cartella _vault]
    python tools/vault-progetto.py --autotest

`verifica` esce con 0 se il vault c'e' ed e' integro, 1 se manca qualcosa, e lo elenca.
`togli` rimuove i collegamenti e la configurazione, mai il contenuto delle cartelle vere.
"""

from __future__ import annotations

import argparse
import json
import os
import shutil
import subprocess
import sys
from pathlib import Path

COLLEGAMENTI = [("memoria", ".claude/memory"), ("contesto", ".claude/context"), ("docs", "docs")]
PLUGIN = ["obsidian42-brat", "new-3d-graph", "embed-html"]
FILE_PLUGIN = ["main.js", "manifest.json", "styles.css", "data.json"]
CORE = ["file-explorer", "global-search", "switcher", "graph", "backlink", "canvas", "outgoing-link", "tag-pane",
        "properties", "page-preview", "note-composer", "command-palette", "editor-status", "bookmarks", "outline",
        "word-count", "file-recovery"]
RIFERIMENTO = Path.home() / ".config" / "vault-riferimento.txt"


def e_collegamento(p: Path) -> bool:
    """Vero per un collegamento simbolico e per una giunzione di Windows."""
    if p.is_symlink():
        return True
    try:
        return bool(getattr(os.lstat(p), "st_file_attributes", 0) & 0x400)  # FILE_ATTRIBUTE_REPARSE_POINT
    except OSError:
        return False


def collega(nome: Path, bersaglio: Path) -> None:
    if os.name == "nt":
        r = subprocess.run(["cmd", "/c", "mklink", "/J", str(nome), str(bersaglio)], capture_output=True, text=True)
        if r.returncode != 0:
            raise OSError("giunzione non creata: " + (r.stdout + r.stderr).strip())
    else:
        os.symlink(bersaglio, nome, target_is_directory=True)


def scollega(p: Path) -> None:
    """Toglie il collegamento e mai cio' a cui punta."""
    if not e_collegamento(p):
        raise OSError("%s non e' un collegamento: non lo tocco" % p)
    if os.name == "nt" and not p.is_symlink():
        os.rmdir(p)
    else:
        os.unlink(p)


def vault_di_riferimento(esplicito: str | None) -> Path | None:
    candidati = [esplicito] if esplicito else []
    try:
        candidati += [r.split("#", 1)[0].strip() for r in RIFERIMENTO.read_text(encoding="utf-8-sig").splitlines()]
    except OSError:
        pass
    for c in candidati:
        if c and (Path(c) / ".obsidian" / "plugins").is_dir():
            return Path(c)
    return None


def crea(radice: Path, cartella: str, da_vault: str | None, ignora: bool) -> list:
    righe = []
    vault = radice / cartella
    vault.mkdir(exist_ok=True)
    for nome, vero in COLLEGAMENTI:
        bersaglio, link = radice / vero, vault / nome
        if not bersaglio.is_dir():
            righe.append("saltato %s: %s non esiste in questo progetto" % (nome, vero))
            continue
        if link.exists() or e_collegamento(link):
            if not e_collegamento(link):
                raise OSError("%s esiste e non e' un collegamento: non lo sostituisco" % link)
            righe.append("gia' presente %s" % nome)
            continue
        collega(link, bersaglio.resolve())
        righe.append("collegato %s -> %s" % (nome, vero))
    conf = vault / ".obsidian"
    conf.mkdir(exist_ok=True)

    def scrivi_se_assente(nome, dato):
        f = conf / nome
        if not f.exists():
            f.write_text(json.dumps(dato, ensure_ascii=False, indent=2) + "\n", encoding="utf-8", newline="\n")

    scrivi_se_assente("core-plugins.json", {n: True for n in CORE})
    scrivi_se_assente("app.json", {"alwaysUpdateLinks": True, "newLinkFormat": "relative", "useMarkdownLinks": True})
    origine = vault_di_riferimento(da_vault)
    installati = []
    if origine:
        for nome in PLUGIN:
            sorgente = origine / ".obsidian" / "plugins" / nome
            if not (sorgente / "main.js").is_file():
                righe.append("plugin %s assente nel vault di riferimento" % nome)
                continue
            dest = conf / "plugins" / nome
            dest.mkdir(parents=True, exist_ok=True)
            for f in FILE_PLUGIN:
                if (sorgente / f).is_file() and not (dest / f).exists():
                    shutil.copy2(sorgente / f, dest / f)
            installati.append(nome)
        righe.append("plugin copiati dal vault di riferimento: " + (", ".join(installati) or "nessuno"))
    else:
        righe.append("nessun vault di riferimento: da Obsidian installare " + ", ".join(PLUGIN)
                     + " (oppure indicare un vault con --da-vault o in %s)" % RIFERIMENTO)
    f = conf / "community-plugins.json"
    if not f.exists():
        f.write_text(json.dumps(installati) + "\n", encoding="utf-8", newline="\n")
    riga = cartella.strip("/") + "/"
    gi = radice / ".gitignore"
    presenti = gi.read_text(encoding="utf-8-sig").splitlines() if gi.is_file() else []
    gia = subprocess.run(["git", "-C", str(radice), "check-ignore", "-q", riga + "x"], capture_output=True).returncode == 0
    if gia or riga in [r.strip() for r in presenti] or ("/" + riga) in [r.strip() for r in presenti]:
        righe.append(".gitignore ignora gia' %s" % riga)
    elif ignora:
        with gi.open("a", encoding="utf-8", newline="\n") as out:
            out.write(("" if not presenti or presenti[-1] == "" else "\n") + "# vista Obsidian del progetto: si ricrea con vault-progetto.py crea\n" + riga + "\n")
        righe.append("aggiunta al .gitignore la riga %s" % riga)
    else:
        righe.append("DA FARE: %s non e' ignorata da git; aggiungere la riga al .gitignore o rilanciare con --ignora" % riga)
    return righe


def verifica(radice: Path, cartella: str) -> list:
    """I difetti del vault; lista vuota se e' integro."""
    vault = radice / cartella
    if not (vault / ".obsidian").is_dir():
        return ["il vault non esiste: %s" % vault]
    guai = []
    for nome, vero in COLLEGAMENTI:
        link, bersaglio = vault / nome, radice / vero
        if not bersaglio.is_dir():
            continue
        if not e_collegamento(link):
            guai.append("%s non e' un collegamento a %s" % (nome, vero))
        elif not link.is_dir() or link.resolve() != bersaglio.resolve():
            guai.append("%s e' un collegamento rotto o punta altrove" % nome)
    try:
        attivi = json.loads((vault / ".obsidian" / "community-plugins.json").read_text(encoding="utf-8-sig"))
    except (OSError, ValueError):
        attivi = []
    for nome in PLUGIN:
        if nome not in attivi or not (vault / ".obsidian" / "plugins" / nome / "main.js").is_file():
            guai.append("plugin di base non installato: %s" % nome)
    r = subprocess.run(["git", "-C", str(radice), "check-ignore", "-q", cartella.strip("/") + "/x"], capture_output=True)
    if r.returncode == 1:
        guai.append("%s non e' ignorata da git: una vista non si versiona" % cartella)
    return guai


def togli(radice: Path, cartella: str) -> list:
    vault = radice / cartella
    righe = []
    for nome, _ in COLLEGAMENTI:
        link = vault / nome
        if e_collegamento(link):
            scollega(link)
            righe.append("tolto il collegamento %s" % nome)
        elif link.exists():
            raise OSError("%s non e' un collegamento: mi fermo senza toccare niente altro" % link)
    if (vault / ".obsidian").is_dir():
        shutil.rmtree(vault / ".obsidian")
        righe.append("tolta la configurazione")
    try:
        vault.rmdir()
        righe.append("tolta la cartella " + cartella)
    except OSError:
        righe.append("la cartella %s contiene altro e resta" % cartella)
    return righe


def autotest() -> int:
    import tempfile
    esiti = []

    def caso(nome, ok, dettaglio=""):
        esiti.append(ok)
        print(("ok    " if ok else "ROSSO ") + nome + ("" if ok else "  " + str(dettaglio)))

    with tempfile.TemporaryDirectory(prefix="vault-") as tmp:
        base = Path(tmp)
        prj, rif = base / "progetto", base / "riferimento"
        (prj / ".claude/memory").mkdir(parents=True)
        (prj / "docs").mkdir()
        (prj / ".claude/memory/index.md").write_text("stato\n", encoding="utf-8")
        subprocess.run(["git", "-C", str(prj), "init", "-q"], capture_output=True)
        for nome in PLUGIN[:2]:
            d = rif / ".obsidian/plugins" / nome
            d.mkdir(parents=True)
            (d / "main.js").write_text("// codice\n", encoding="utf-8")
            (d / "manifest.json").write_text("{}", encoding="utf-8")
        righe = crea(prj, "_vault", str(rif), ignora=True)
        v = prj / "_vault"
        caso("la memoria si vede dal vault attraverso un collegamento", e_collegamento(v / "memoria") and (v / "memoria/index.md").read_text(encoding="utf-8") == "stato\n", righe)
        caso("una cartella che il progetto non ha si salta e lo si dice", not (v / "contesto").exists() and any("saltato contesto" in r for r in righe), righe)
        (v / "memoria/nuova.md").write_text("scritta dal vault\n", encoding="utf-8")
        caso("cio' che si scrive nel vault finisce nel file vero", (prj / ".claude/memory/nuova.md").is_file())
        attivi = json.loads((v / ".obsidian/community-plugins.json").read_text(encoding="utf-8"))
        caso("i plugin presenti nel vault di riferimento si copiano e si attivano", attivi == PLUGIN[:2] and (v / ".obsidian/plugins" / PLUGIN[0] / "main.js").is_file(), attivi)
        caso("un plugin assente nel riferimento si dichiara", any(PLUGIN[2] in r and "assente" in r for r in righe), righe)
        caso("con --ignora la cartella del vault entra nel .gitignore", "_vault/" in (prj / ".gitignore").read_text(encoding="utf-8"))
        guai = verifica(prj, "_vault")
        caso("la verifica segnala il plugin di base che manca, e solo quello", guai == ["plugin di base non installato: " + PLUGIN[2]], guai)
        prima = sorted(p.name for p in (v / ".obsidian").iterdir())
        crea(prj, "_vault", str(rif), ignora=True)
        caso("rilanciare non duplica e non sovrascrive", sorted(p.name for p in (v / ".obsidian").iterdir()) == prima
             and (prj / ".gitignore").read_text(encoding="utf-8").count("_vault/") == 1)
        togli(prj, "_vault")
        caso("togliere il vault non tocca la memoria vera", not v.exists() and (prj / ".claude/memory/index.md").is_file() and (prj / ".claude/memory/nuova.md").is_file())
        caso("negativo: senza vault la verifica lo dice", verifica(prj, "_vault")[0].startswith("il vault non esiste"))
        (prj / "_vault").mkdir()
        (prj / "_vault/memoria").mkdir()
        try:
            crea(prj, "_vault", None, ignora=False)
            rifiutato = False
        except OSError:
            rifiutato = True
        caso("negativo: una cartella vera al posto del collegamento non si sostituisce", rifiutato)
        altro = base / "senza"
        (altro / "docs").mkdir(parents=True)
        subprocess.run(["git", "-C", str(altro), "init", "-q"], capture_output=True)
        r2 = crea(altro, "_vault", str(base / "inesistente"), ignora=False)
        caso("senza vault di riferimento scrive la configurazione e dice che cosa installare",
             any("nessun vault di riferimento" in r for r in r2) and json.loads((altro / "_vault/.obsidian/community-plugins.json").read_text(encoding="utf-8")) == [], r2)
        caso("senza --ignora dichiara il da fare e non tocca il .gitignore", any(r.startswith("DA FARE") for r in r2) and not (altro / ".gitignore").exists(), r2)
        togli(altro, "_vault")
    print("%d prove, %d fallite" % (len(esiti), esiti.count(False)))
    return 1 if False in esiti else 0


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    ap.add_argument("azione", nargs="?", choices=["crea", "verifica", "togli"])
    ap.add_argument("--radice", default=".")
    ap.add_argument("--cartella", default="_vault")
    ap.add_argument("--da-vault")
    ap.add_argument("--ignora", action="store_true", help="aggiunge la cartella del vault al .gitignore")
    ap.add_argument("--autotest", action="store_true")
    a = ap.parse_args()
    if a.autotest:
        return autotest()
    if not a.azione:
        ap.error("serve un'azione: crea, verifica o togli")
    radice = Path(a.radice).resolve()
    try:
        if a.azione == "crea":
            for r in crea(radice, a.cartella, a.da_vault, a.ignora):
                print("  " + r)
            print("vault pronto: in Obsidian, «Apri cartella come vault» su %s" % (radice / a.cartella))
            return 0
        if a.azione == "togli":
            for r in togli(radice, a.cartella):
                print("  " + r)
            return 0
        guai = verifica(radice, a.cartella)
        for g in guai:
            print("  " + g)
        print("vault: %d problemi" % len(guai))
        return 1 if guai else 0
    except OSError as err:
        print("errore: %s" % err, file=sys.stderr)
        return 2


if __name__ == "__main__":
    sys.exit(main())
