---
name: start-unit
description: Load context and begin a single plan unit
disable-model-invocation: true
---

# /start-unit $ARGUMENTS

Begin exactly one plan unit — no scope creep.

1. Read `$ARGUMENTS` and confirm its **entry dependency** is satisfied. If not, stop and say so.
2. Read the relevant conventions: `AGENTS.md` + scoped `.cursor/rules/*.mdc` for the files you'll touch; `docs/architecture.md` for the area.
3. Restate the unit's **verification gate** as your definition of done; keep it visible.
4. Create a branch (`git checkout -b`): `<phase>/<unit>` for a phase unit, or `<issue-id>-<slug>` for a `plans/features/` unit (the tracker auto-links the PR from the issue id). Implement only what this unit specifies. Follow `.cursor/rules/model-policy.mdc`.
5. As you go, verify each gate item and gather its evidence.

Don't update status docs or open the PR yet — that's `/close-unit`.
