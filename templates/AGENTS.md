# {{PROJECT_NAME}} — Agent Constitution

> **For all AI coding agents** (Cursor, Claude Code, Aider, Codex). Read this first. Single source of truth for **conventions**. `CLAUDE.md` imports this file via `@AGENTS.md`.
>
> Context is split by volatility:
> | Doc | Holds | Changes |
> |---|---|---|
> | `VISION.md` | product thesis | rarely |
> | **`AGENTS.md`** (this file) | conventions, antipatterns, landing pad, roadmap index | slowly |
> | `docs/architecture.md` | feature specs, data flows | slowly |
> | `docs/git-workflow.md` | git / CI / review process | rarely |
> | `plans/` | Deep-lane unit specs (open only) + optional project design notes | per Deep-lane unit |
> | `docs/status.md` | changelog, open technical threads | every session |
> | `DECISIONS.md` | decisions expensive to reverse | when one is made |

---

## 📍 Landing pad — where am I / what next

- **Product:** {{ONE_LINER}} (see `VISION.md`).
- **Tracker:** **{{TRACKER}}** — <team/project link, or `gh issue list` for this repo>. Issues live here and nowhere else: `/start-unit <id>` fetches from this tracker (Linear MCP, or `gh issue view`) and stops if it can't. Delivery status lives there, not here.
- **Active project:** <tracker project + one-line outcome>. Optional design notes: `plans/<project>/README.md`.
- **Next unit:** <issue id> — the Todo issue you're about to build. Deep lane only: `plans/features/<issue-id>-<slug>.md` after `/plan <issue-id>`.
- **Working rhythm:** pick the lane by risk (`PLAYBOOK.md` → *Proportional rigor*): **fast** (human "go" in chat → issue as record → fix + evidence → PR), **standard** (Todo issue → `/start-unit` → `/close-unit`; the issue is the spec), **deep** (`/plan <issue-id>` → human review → `/start-unit` → `/close-unit`). Every lane: tracker issue, branch `<issue-id>-<slug>`, PR, gate evidence.
- **WIP limit:** one issue being built in this repo at a time (+ at most one read-only investigation). Open PRs awaiting review don't count. An issue is a **session-sized** unit: in-scope tweaks are commits in its PR, out-of-scope finds are a new issue.
- **Active background work:** none currently. *(coordinator / automations are off by default — see `docs/coordinator.md` for the trigger)*

---

## What we're building (short)

<2–4 sentences. Full thesis in `VISION.md`; feature specs in `docs/architecture.md`.>

## Roadmap

The tracker owns it — projects, milestones, and issues live in **{{TRACKER}}** (link in the landing pad). This file only says where the code is. History of what shipped: `docs/status.md`.

## Stack (locked in)

| Layer | Choice | Notes |
|---|---|---|
| | | |

## How to run

```bash
<the canonical run commands>
```

---

## Architecture conventions

<The rules that matter. Auth, data access, error handling, logging, state, safety, naming. Keep these tight and specific — this is the heart of the constitution.>

## Common-mistake antipatterns

- **Don't** <the recurring mistakes, stated as "don't X — do Y">.

## What we're explicitly NOT building (or deferring)

- <scope fence>

---

## Working with multiple AI agents

- **Single source of truth for conventions:** this file. **Thesis:** `VISION.md`. **How it works:** `docs/architecture.md`.
- **Git workflow is non-negotiable:** never commit to `main`. Every issue goes on a branch `<issue-id>-<slug>` (the tracker auto-links the PR) → commits → push → PR → CI green → review → merge. No meaningful change merges without an issue. Full model: `docs/git-workflow.md`.
- **Coordinators (Cursor Projects) and supervisors obey this file too.** They plan, delegate, verify evidence, and report; they never write code or merge. Their brief: `docs/coordinator.md`.
- **Scoped rules are Cursor-native but bind every agent.** Cursor auto-loads `.cursor/rules/*.mdc` by glob; Claude Code and Codex do not — before editing a file, read the `.mdc` whose `globs` match it.
- **When you change a convention/architecture:** update `AGENTS.md` first, log it in `DECISIONS.md`, then update the relevant `.cursor/rules/*.mdc`.
- **When you finish a unit:** verify its gate, update `docs/status.md` + the landing pad, push the branch and open the PR (don't merge — that's the human gate).
- **The issue is the spec.** Deep-lane units also get an in-repo plan file (`plans/features/`), not a machine-local one. Tool plan modes are ephemeral scratch. `plans/` is never where you look for work.
- **One fact, one home.** Link to paths + line numbers; never paste full files into prompts.
- **Automation:** model/tool policy in `.cursor/rules/model-policy.mdc`; rituals in `.agents/skills/` (`/plan`, `/start-unit`, `/close-unit`, `/context-sync`); guard via `.githooks/pre-commit` (enable with `git config core.hooksPath .githooks`) + `.cursor/hooks.json`; subagents in `.claude/agents/`; unattended jobs' prompts in `.cursor/automations/`.

## Quick reference

| Need | Go to |
|---|---|
| Product thesis | `VISION.md` |
| How it works | `docs/architecture.md` |
| What's next | {{TRACKER}} — link in the landing pad. Nowhere else. |
| Deep-lane specs + gates | `plans/features/` (open units only) |
| Coordinator brief | `docs/coordinator.md` |
| Git / CI / review workflow | `docs/git-workflow.md` |
| What shipped | `docs/status.md` |
| Decisions expensive to reverse | `DECISIONS.md` |
