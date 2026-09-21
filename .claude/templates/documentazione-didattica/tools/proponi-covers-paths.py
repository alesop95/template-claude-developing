# -*- coding: utf-8 -*-
"""Propone i `covers-paths` di una scheda didattica estraendoli dal testo, senza dedurli.

## Perche' esiste (pendente T-9)

Cinquantatre schede su sessantuno non dichiarano quali file del codice trattano, e quel campo e'
l'unico aggancio meccanico fra una spiegazione e il codice che spiega: senza, non si puo' chiedere
"quali schede parlano di un file appena cambiato", che e' l'unico modo di accorgersi che una
spiegazione e' diventata falsa.

## La distinzione che rende il lavoro lecito, ed e' tutto il punto

Il registro dei pendenti dichiara che questo lavoro **non e' automatizzabile**, perche' dedurre i
percorsi dal testo produrrebbe percorsi plausibili e non percorsi veri, che e' il tipo di errore
peggiore perche' sembra un dato.

Quella affermazione resta vera e questo strumento non la contraddice, perche' **non deduce niente**.
Estrae le stringhe che la scheda ha gia' scritto fra apici inversi, tiene solo quelle che
corrispondono a un file realmente presente sul disco, e le ordina per quante volte la scheda le
nomina. Un percorso che la scheda non nomina non compare mai nella proposta.

La differenza fra dedurre ed estrarre non e' un cavillo: **una deduzione puo' essere sbagliata in
modo invisibile, un'estrazione al massimo e' incompleta in modo visibile.** Le schede che parlano di
un file senza nominarlo restano scoperte, e lo strumento lo dichiara invece di indovinare.

## Che cosa resta al giudizio umano

Due cose, ed e' per questo che lo strumento **propone** invece di scrivere. La prima e' la potatura:
una scheda puo' nominare dieci file e trattarne tre, e distinguere l'argomento dal contorno richiede
di aver capito la scheda. La seconda sono i file citati e non piu' esistenti, che lo strumento
elenca a parte perche' sono un'informazione a se': dicono quali schede parlano di codice cancellato.

## Uso

    python tools/proponi-covers-paths.py > proposta.txt
    python tools/proponi-covers-paths.py --solo-mancanti

Non scrive mai dentro le schede.
"""

import argparse
import io
import os
import re
import sys

CARTELLA = os.path.join(".claude", "context")
PREFISSO = "refactor-"

# Una stringa fra apici inversi che assomiglia a un percorso del repository: comincia con una delle
# radici note e finisce con un'estensione di codice o configurazione. Volutamente stretta: un falso
# positivo qui diventerebbe un dato sbagliato in un campo che serve a dare fiducia.
RE_CODICE = re.compile(r"`([^`\n]+)`")
RADICI = ("src/", "functions/", "public/", "scripts/", "tools/", "email-templates/")
ESTENSIONI = (".ts", ".tsx", ".js", ".json", ".rules", ".py", ".mjml", ".css", ".html")


def ha_front_matter(testo):
    return testo.lstrip().startswith("---")


def indice_nomi():
    """Mappa da nome file a elenco dei percorsi che lo portano, dentro le radici note.

    Serve a risolvere i nomi nudi: molte schede scrivono `useFamilyData.ts` senza la cartella,
    perche' chi le ha scritte aveva il progetto in testa. Risolverli e' ancora estrazione, non
    deduzione, **a una condizione**: si accetta solo la corrispondenza unica. Se due file portano
    lo stesso nome la scheda non ha detto quale, e sceglierne uno sarebbe inventare.
    """
    mappa = {}
    for radice in RADICI:
        if not os.path.isdir(radice):
            continue
        for cartella, sottocartelle, file in os.walk(radice):
            sottocartelle[:] = [d for d in sottocartelle if d not in ("node_modules", "__pycache__")]
            for n in file:
                if n.endswith(ESTENSIONI):
                    mappa.setdefault(n, []).append(os.path.join(cartella, n).replace(os.sep, "/"))
    return mappa


NOMI = None


def candidati(testo):
    """I percorsi nominati dalla scheda, con quante volte ciascuno compare, e gli ambigui.

    Restituisce (conta, ambigui). Un nome nudo che corrisponde a piu' file finisce fra gli
    ambigui e non fra i candidati: la scheda non ha detto quale, e questo strumento non sceglie.
    """
    global NOMI
    if NOMI is None:
        NOMI = indice_nomi()

    conta, ambigui = {}, {}
    for grezzo in RE_CODICE.findall(testo):
        s = grezzo.strip()

        # Percorso completo, la forma migliore perche' non ha ambiguita'.
        if s.startswith(RADICI) and s.endswith(ESTENSIONI):
            conta[s] = conta.get(s, 0) + 1
            continue

        # File di configurazione in radice, riconosciuti per nome esatto.
        if s in ("firestore.rules", "firebase.json", "package.json", "tsconfig.json"):
            conta[s] = conta.get(s, 0) + 1
            continue

        # Nome nudo: si risolve solo se la corrispondenza nel repository e' unica.
        if "/" not in s and s.endswith(ESTENSIONI):
            trovati = NOMI.get(s, [])
            if len(trovati) == 1:
                conta[trovati[0]] = conta.get(trovati[0], 0) + 1
            elif len(trovati) > 1:
                ambigui[s] = trovati
    return conta, ambigui


def main(argv=None):
    ap = argparse.ArgumentParser(description="Propone i covers-paths estraendoli dalle schede.")
    ap.add_argument("--solo-mancanti", action="store_true",
                    help="salta le schede che hanno gia' il front matter")
    args = ap.parse_args(argv)

    nomi = sorted(n for n in os.listdir(CARTELLA)
                  if n.startswith(PREFISSO) and n.endswith(".md") and n != PREFISSO + "indice.md")

    senza_nulla, assenti_globali = [], {}
    for nome in nomi:
        percorso = os.path.join(CARTELLA, nome)
        testo = io.open(percorso, encoding="utf-8").read()
        if args.solo_mancanti and ha_front_matter(testo):
            continue

        conta, ambigui = candidati(testo)
        esistono = {p: c for p, c in conta.items() if os.path.exists(p)}
        assenti = {p: c for p, c in conta.items() if not os.path.exists(p)}
        for p, c in assenti.items():
            assenti_globali[p] = assenti_globali.get(p, 0) + c

        print("### %s" % nome)
        if esistono:
            ordinati = sorted(esistono.items(), key=lambda x: (-x[1], x[0]))
            print("    proposta: [%s]" % ", ".join('"%s"' % p for p, _ in ordinati[:6]))
            print("    menzioni: %s" % ", ".join("%s x%d" % (p, c) for p, c in ordinati))
        else:
            print("    NESSUN percorso esistente nominato: serve lettura umana")
            senza_nulla.append(nome)
        if assenti:
            print("    citati ma NON piu' esistenti: %s"
                  % ", ".join("%s x%d" % (p, c) for p, c in sorted(assenti.items())))
        if ambigui:
            print("    nomi ambigui, NON risolti: %s"
                  % "; ".join("%s -> %s" % (n, "|".join(v)) for n, v in sorted(ambigui.items())))
        print()

    print("=" * 72)
    print("schede senza nessun percorso estraibile: %d" % len(senza_nulla))
    for n in senza_nulla:
        print("  %s" % n)
    print()
    print("file citati dalle schede e non piu' esistenti: %d" % len(assenti_globali))
    for p, c in sorted(assenti_globali.items(), key=lambda x: -x[1]):
        print("  %-60s citato %d volte" % (p, c))
    return 0


if __name__ == "__main__":
    sys.exit(main())
