#!/usr/bin/env python3
"""Prove dell'installatore di instradamento-modelli, cioe' della parte che
scrive su un file che non e' suo: il settings.json di un account.

Che cosa misurano. La mod ha le sue prove, eseguite con `claude plugin test`;
qui si prova l'altra meta', che e' quella capace di fare danno: una fusione che
perde una chiave preesistente di un settings.json costa all'utente la
configurazione del suo account, e il danno non si vede finche' qualcosa non
smette di funzionare per un'altra ragione apparente. Ogni caso ha quindi la
forma «dopo l'operazione, che cosa c'e' ancora che c'era prima».

Uso: python test-instradamento.py
"""

import json
import os
import shutil
import subprocess
import sys
import tempfile

RADICE = os.path.dirname(os.path.abspath(__file__))
FUSIONE = os.path.join(RADICE, "merge-instradamento-settings.js")
SEPARATORE = ";" if sys.platform == "win32" else ":"

esiti = []


def verifica(nome, condizione, dettaglio=""):
    esiti.append((nome, bool(condizione), dettaglio))


def fondi(settings, mod, *extra):
    return subprocess.run(
        ["node", FUSIONE, settings, mod] + list(extra),
        capture_output=True, text=True,
    )


def mod_finta(base):
    cartella = os.path.join(base, "mod-finta")
    os.makedirs(os.path.join(cartella, ".claude-plugin"), exist_ok=True)
    with open(os.path.join(cartella, ".claude-plugin", "plugin.json"), "w", encoding="utf-8") as f:
        json.dump({"name": "mod-finta"}, f)
    return cartella


def leggi(percorso):
    with open(percorso, encoding="utf-8") as f:
        return json.load(f)


def main():
    if shutil.which("node") is None:
        print("SALTATO: Node.js non e' nel PATH, la fusione non e' provabile qui")
        return 0

    base = tempfile.mkdtemp(prefix="prova-instradamento-")
    try:
        mod = mod_finta(base)
        altra = os.path.join(base, "altra-mod")
        os.makedirs(altra, exist_ok=True)
        settings = os.path.join(base, "settings.json")

        # Un settings.json realistico: altre chiavi, un hook, e una cartella di
        # plugin gia' registrata da qualcun altro.
        iniziale = {
            "autoMemoryEnabled": False,
            "permissions": {"allow": ["Bash(ls)"]},
            "hooks": {"SessionEnd": [{"hooks": [{"type": "command", "command": "echo"}]}]},
            "env": {"ALTRA_VARIABILE": "1", "CLAUDE_CODE_PLUGIN_DIRS": altra},
        }
        with open(settings, "w", encoding="utf-8") as f:
            json.dump(iniziale, f, indent=2)

        # 1. Registrazione
        esito = fondi(settings, mod)
        dati = leggi(settings)
        cartelle = dati["env"]["CLAUDE_CODE_PLUGIN_DIRS"].split(SEPARATORE)
        verifica("la registrazione esce con zero", esito.returncode == 0, esito.stderr)
        verifica("la mod risulta registrata", os.path.abspath(mod) in [os.path.abspath(c) for c in cartelle])
        verifica("la cartella di plugin altrui resta", os.path.abspath(altra) in [os.path.abspath(c) for c in cartelle])
        verifica("le altre variabili d'ambiente restano", dati["env"].get("ALTRA_VARIABILE") == "1")
        verifica("le chiavi preesistenti restano", set(iniziale).issubset(set(dati)))
        verifica("l'hook preesistente resta", dati["hooks"]["SessionEnd"][0]["hooks"][0]["command"] == "echo")

        # 2. Idempotenza: una seconda corsa non duplica
        fondi(settings, mod)
        cartelle = leggi(settings)["env"]["CLAUDE_CODE_PLUGIN_DIRS"].split(SEPARATORE)
        quante = len([c for c in cartelle if os.path.abspath(c) == os.path.abspath(mod)])
        verifica("una seconda corsa non duplica la voce", quante == 1, "trovate %d" % quante)

        # 3. Rimozione
        esito = fondi(settings, mod, "--rimuovi")
        dati = leggi(settings)
        cartelle = dati.get("env", {}).get("CLAUDE_CODE_PLUGIN_DIRS", "").split(SEPARATORE)
        verifica("la rimozione esce con zero", esito.returncode == 0, esito.stderr)
        verifica("dopo la rimozione la mod non c'e'", os.path.abspath(mod) not in [os.path.abspath(c) for c in cartelle if c])
        verifica("dopo la rimozione la cartella altrui resta", os.path.abspath(altra) in [os.path.abspath(c) for c in cartelle if c])
        verifica("dopo la rimozione le chiavi restano", set(iniziale).issubset(set(dati)))

        # 4. Un settings.json illeggibile non si sovrascrive
        rotto = os.path.join(base, "rotto.json")
        with open(rotto, "w", encoding="utf-8") as f:
            f.write("{ questo non e JSON")
        esito = fondi(rotto, mod)
        with open(rotto, encoding="utf-8") as f:
            contenuto = f.read()
        verifica("un settings.json illeggibile fa fallire", esito.returncode != 0)
        verifica("un settings.json illeggibile resta intatto", contenuto == "{ questo non e JSON")

        # 5. Una cartella che non e' una mod viene rifiutata
        esito = fondi(settings, altra)
        verifica("una cartella senza plugin.json viene rifiutata", esito.returncode != 0)

        # 6. Un file che non esiste si crea con la sola chiave attesa
        nuovo = os.path.join(base, "nuovo", "settings.json")
        esito = fondi(nuovo, mod)
        dati = leggi(nuovo)
        verifica("su un file nuovo la registrazione riesce", esito.returncode == 0, esito.stderr)
        verifica("il file nuovo contiene solo env", list(dati) == ["env"])
    finally:
        shutil.rmtree(base, ignore_errors=True)

    falliti = [e for e in esiti if not e[1]]
    for nome, ok, dettaglio in esiti:
        print(("  ok   " if ok else "  FALLITO ") + nome + ((" - " + dettaglio.strip()) if (not ok and dettaglio) else ""))
    print("\n%d casi, %d falliti" % (len(esiti), len(falliti)))
    return 1 if falliti else 0


if __name__ == "__main__":
    sys.exit(main())
