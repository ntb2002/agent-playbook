---
name: start-unit
description: Load context and begin a single plan unit
disable-model-invocation: true
---

# /start-unit $ARGUMENTS

Begin exactly one plan unit — no scope creep.

1. **Fetch the unit from Linear.** In continuous mode `$ARGUMENTS` is a Linear issue id (`SP-7`, `NV-3`, …). Use the Linear MCP (`get_issue`) as the first read. GitHub Issues are not the tracker and are unused. `plans/` is not a backlog — `plans/features/<id>-*.md` exists only after `/plan-feature` for an already-accepted Linear issue. Do not search GitHub, Notion, or a planning markdown file for “the issue.” If Linear MCP is missing, stop and say so. If the human named sub-issues, fetch those Linear ids too; they are still Linear issues, not extra GitHub tickets.
2. Confirm the issue's **entry dependency** is satisfied (merged PRs, infra, parent/blockers on the Linear issue). If not, stop and say so.
3. Read the relevant conventions: `AGENTS.md` + scoped `.cursor/rules/*.mdc` for the files you'll touch; `docs/architecture.md` for the area. Prefer the Linear acceptance criteria over any stale plan file if they disagree.
4. Restate the unit's **verification gate** as your definition of done; keep it visible.
5. Create a branch (`git checkout -b`): `<phase>/<unit>` for a phase unit, or `<issue-id>-<slug>` for a tracker-driven unit (the tracker auto-links the PR from the issue id). Implement only what this unit specifies. Follow `.cursor/rules/model-policy.mdc`.
6. As you go, verify each gate item and gather its evidence. For iOS `[ARTIFACT]` taps, the Xcode MCP must appear in **this** session's live tool catalog (`DeviceInteraction*`). Cached descriptors on disk do not count. If it is absent, gather `[CI]` evidence and leave the taps for a local session with Xcode connected — do not invent a GitHub issue or a `[MANUAL]` human for work the MCP would have done.

Don't update status docs or open the PR yet — that's `/close-unit`.
