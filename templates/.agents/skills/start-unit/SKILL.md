---
name: start-unit
description: Fetch one tracker issue, load context, and begin building it on its branch
disable-model-invocation: true
---

# /start-unit $ARGUMENTS

Begin exactly one issue — no scope creep. `$ARGUMENTS` is an issue id (`SP-7`, `NV-3`, or `#42` on the GitHub tier).

1. **Fetch the issue from the declared tracker.** `AGENTS.md`'s landing pad names it. Linear → Linear MCP (`get_issue`) as the first read. GitHub Issues → `gh issue view <n> --comments`. That tracker is the only place work comes from: do not search the other tracker, Notion, or a planning markdown file for "the issue." **If you cannot fetch it, stop and say so** — do not guess from `plans/` and do not proceed on a pasted summary unless the human explicitly says the tracker is down. If the human named sub-issues, fetch those too.
2. Confirm the issue is in **Todo** (or was filed straight into In Progress by a Fast-lane approval in this conversation) and that its **entry dependency** is satisfied (merged PRs, infra, `blocked by` links). If not, stop and say so. Check the WIP limit: if another issue is already being built in this repo, stop and ask which one to continue.
3. Load the spec. **The issue is the spec.** If a Deep-lane plan file exists at `plans/features/<issue-id>-*.md`, read it too, and prefer the issue's acceptance criteria if they disagree. If the issue still has a `## Needs human` section or no acceptance criteria, stop — it isn't ready to build.
4. Read the relevant conventions: `AGENTS.md` + scoped `.cursor/rules/*.mdc` for the files you'll touch; `docs/architecture.md` for the area.
5. Restate the **verification gate** as your definition of done; keep it visible.
6. Create the branch: `git checkout -b <issue-id>-<slug>` (the tracker auto-links the PR from the id). Implement only what this issue specifies. In-scope tweaks you discover are commits here; out-of-scope finds become a new issue (Fast lane if you're fixing it now, a one-line Triage capture if not) — never silent extra scope. Follow `.cursor/rules/model-policy.mdc`.
7. As you go, verify each gate item and gather its evidence. For iOS `[ARTIFACT]` taps, the Xcode MCP must appear in **this** session's live tool catalog (`DeviceInteraction*`). Cached descriptors on disk do not count. If it is absent, gather `[CI]` evidence and leave the taps for a local session with Xcode connected — do not invent a `[MANUAL]` human for work the MCP would have done.

Don't update status docs or open the PR yet — that's `/close-unit`.
