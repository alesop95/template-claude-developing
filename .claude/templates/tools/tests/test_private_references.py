"""Riferimenti personali: avvisi senza introdurre un blocco sui casi ambigui."""

import importlib.util
from pathlib import Path


SCRIPT = Path(__file__).resolve().parents[2] / "anonymization/tools/Test-Anonymization.py"
spec = importlib.util.spec_from_file_location("anonymization_tested", SCRIPT)
scanner = importlib.util.module_from_spec(spec)
spec.loader.exec_module(scanner)


def test_personal_paths_and_declared_cloud_are_nonblocking_warnings(tmp_path):
    source = tmp_path / "prova.md"
    source.write_text("C:/Users/" + "persona/Studio\nServizioPersonale\nC:/Users/<utente>/Studio\n", encoding="utf-8")
    config = {key: [] for key in ("reti_documentali_ammesse", "ip_ammessi", "prefissi_reali", "mac_ammessi_prefissi", "email_ammesse", "nomi_propri")}
    config["servizi_cloud_personali"] = ["ServizioPersonale"]
    findings, _ = scanner.analizza(config, [(str(source), "tracciato")])
    category = "RIFERIMENTO PERSONALE da valutare"
    assert len(findings[category]) == 2
    assert category not in scanner.BLOCCANTI
    assert all("oscur" not in item[2] or "<" in item[2] for item in findings[category])
