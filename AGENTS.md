# Istruzioni per Codex

Questo repository e' il template del sistema di progetto condiviso da Claude Code e Codex. `CLAUDE.md` e' la fonte canonica delle istruzioni di questo repository: leggilo per intero prima di operare. Lo standard completo vive in `.claude/PROJECT-SYSTEM.md`.

Esegui `python .claude/templates/tools/sync-codex-skills.py --project-root . --check` all'inizio della sessione. Le skill canoniche vivono in `.claude/skills/`; gli omonimi file sotto `.agents/skills/` sono wrapper generati di discovery per Codex e rimandano alla fonte canonica. Se il controllo segnala drift, rigenerali con lo stesso comando senza `--check` e riesegui la verifica.

Le operazioni di `git add`, commit, push e deploy restano manuali dell'utente. Non modificare le variazioni estranee gia' presenti nel working tree.
