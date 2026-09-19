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
> | `plans/` | active roadmap + per-unit specs with gates | per active phase |
> | `docs/status.md` | changelog | every session |
> | `DECISIONS.md` | decisions expensive to reverse | when one is made |

---

## 📍 Landing pad — where am I / what next

- **Product:** {{ONE_LINER}} (see `VISION.md`).
- **Mode:** phase *(pre-v1)* | continuous *(live — tracker owns what's next)*. <pick one>
- **Current phase:** <phase + one-line focus>. Plan: `plans/<phase>/`. *(phase mode)*
- **Tracker:** <Linear team/project link>. *(continuous mode — engineering status lives there, not here. Work items are Linear issues. GitHub Issues are not used.)*
- **Next actionable unit:** <Linear issue id> → `plans/features/<issue-id>-<slug>.md` after `/plan-feature`. *(phase mode: `plans/<phase>/<unit>.md`)*
- **Working rhythm:** one plan unit → verify its gate → update `docs/status.md` + this landing pad → branch + PR → merge → next.
- **Active background work:** none currently. *(coordinator / automations, if any: see `docs/coordinator.md`)*

---

## What we're building (short)

<2–4 sentences. Full thesis in `VISION.md`; feature specs in `docs/architecture.md`.>

## Phase roadmap

| Phase | Status | Focus |
|------|--------|-------|
| 1 | ⬜ | <focus> |

Active-phase detail + gates: `plans/`. History: `docs/status.md`.

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
- **Git workflow is non-negotiable:** never commit to `main`. Every unit goes on a branch (`<phase>/<unit>`, or `<issue-id>-<slug>` for tracker-driven units) → commits → push → PR → CI green → review → merge. Full model: `docs/git-workflow.md`.
- **Coordinators (Cursor Projects) and supervisors obey this file too.** They plan, delegate, verify evidence, and report; they never write code or merge. Their brief: `docs/coordinator.md`.
- **Scoped rules are Cursor-native but bind every agent.** Cursor auto-loads `.cursor/rules/*.mdc` by glob; Claude Code and Codex do not — before editing a file, read the `.mdc` whose `globs` match it.
- **When you change a convention/architecture:** update `AGENTS.md` first, log it in `DECISIONS.md`, then update the relevant `.cursor/rules/*.mdc`.
- **When you finish a unit:** verify its gate, update `docs/status.md` + the landing pad, push the branch and open the PR (don't merge — that's the human gate).
- **Plans are in-repo** (`plans/`), not machine-local. Tool plan modes are ephemeral scratch.
- **One fact, one home.** Link to paths + line numbers; never paste full files into prompts.
- **Automation:** model/tool policy in `.cursor/rules/model-policy.mdc`; rituals in `.agents/skills/` (`/plan-phase`, `/plan-feature`, `/start-unit`, `/close-unit`, `/context-sync`); guard via `.githooks/pre-commit` (enable with `git config core.hooksPath .githooks`) + `.cursor/hooks.json`; subagents in `.claude/agents/`; unattended jobs' prompts in `.cursor/automations/`.

## Quick reference

| Need | Go to |
|---|---|
| Product thesis | `VISION.md` |
| How it works | `docs/architecture.md` |
| Active plan + gates | `plans/` |
| What's next (continuous mode) | Linear — link in the landing pad. Not GitHub Issues. |
| Coordinator brief | `docs/coordinator.md` |
| Git / CI / review workflow | `docs/git-workflow.md` |
| What shipped | `docs/status.md` |
| Decisions expensive to reverse | `DECISIONS.md` |
