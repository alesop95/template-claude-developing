# Istruzioni per Codex

Questo repository è il template del sistema di progetto condiviso da Claude Code e Codex. `CLAUDE.md` è la fonte canonica delle istruzioni di questo repository: leggilo per intero prima di operare. Lo standard completo vive in `.claude/PROJECT-SYSTEM.md`.

Esegui `python .claude/templates/tools/sync-codex-skills.py --project-root . --check` all'inizio della sessione. Le skill canoniche vivono in `.claude/skills/`; gli omonimi file sotto `.agents/skills/` sono wrapper generati di discovery per Codex e rimandano alla fonte canonica. Se il controllo segnala drift, rigenerali con lo stesso comando senza `--check` e riesegui la verifica.

Le regole sempre attive per Claude Code valgono identiche per te, anche se non le carichi in automatico: leggi all'inizio `.claude/rules/chat-non-e-memoria.md`, `.claude/rules/interaction-style.md` e `.claude/rules/git-commands-format.md`. In pratica: a ogni giro di lavoro sostanziale aggiorni memoria e contesto e dichiari in una riga i file scritti; a fine lavoro aggiorni `_notes/RESUME-PROMPT.md` e scrivi in `_notes/COMMIT-MSG.txt` il messaggio di commit proposto, una riga di al massimo 72 caratteri, e lo stesso fai a ogni milestone a metà sessione proponendo di lanciare `chiudi`; la chiusura la esegue l'utente con `.claude/templates/tools/chiudi-sessione.ps1`. Nessun commit porta attribuzioni a un agente: niente `Co-Authored-By` né firme generate, e l'hook `.githooks/commit-msg` rifiuta i messaggi che le contengono.

Le operazioni di `git add`, commit, push e deploy restano manuali dell'utente. Non modificare le variazioni estranee già presenti nel working tree.
