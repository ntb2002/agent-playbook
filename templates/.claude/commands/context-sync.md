---
description: Reconcile the docs with reality after a work session
allowed-tools: Read, Edit, Bash(git status:*), Bash(git diff:*), Bash(git log:*)
---

# /context-sync

Reconcile the context docs with what actually changed. Do **not** write feature code.

1. Inspect: `git status`, `git diff`, recent `git log`.
2. Update **`docs/status.md`** (check off shipped items / add a dated entry). Most updates land here — it's the volatile doc.
3. Update the **`AGENTS.md` landing pad** if the current phase or next-actionable unit changed.
4. If a **convention/architecture** changed: update `AGENTS.md` and/or `docs/architecture.md`, and the relevant `.cursor/rules/*.mdc`.
5. If a **decision expensive to reverse** was made: append to `DECISIONS.md`.
6. Keep `AGENTS.md` lean. One fact, one home — no duplication.

Report a short diff summary of which docs you touched and why.
