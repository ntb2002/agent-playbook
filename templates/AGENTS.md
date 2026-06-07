# {{PROJECT_NAME}} — Agent Constitution

> **For all AI coding agents** (Cursor, Claude Code, Aider, Codex). Read this first. Single source of truth for **conventions**. `.claude/CLAUDE.md` is a thin pointer here.
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
- **Current phase:** <phase + one-line focus>. Plan: `plans/<phase>/`.
- **Next actionable unit:** <unit> → `plans/<phase>/<unit>.md`.
- **Working rhythm:** one plan unit → verify its gate → update `docs/status.md` + this landing pad → branch + PR → merge → next.
- **Active background work:** none currently.

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
- **Git workflow is non-negotiable:** never commit to `main`. Every unit goes on a branch `<phase>/<unit>` → commits → push → PR → CI green → review → merge. Full model: `docs/git-workflow.md`.
- **When you change a convention/architecture:** update `AGENTS.md` first, log it in `DECISIONS.md`, then update the relevant `.cursor/rules/*.mdc`.
- **When you finish a unit:** verify its gate, update `docs/status.md` + the landing pad, push the branch and open the PR (don't merge — that's the human gate).
- **Plans are in-repo** (`plans/`), not machine-local. Tool plan modes are ephemeral scratch.
- **One fact, one home.** Link to paths + line numbers; never paste full files into prompts.
- **Automation:** model/tool policy in `.cursor/rules/model-policy.mdc`; rituals in `.claude/commands/`; guard via `.githooks/pre-commit` (enable with `git config core.hooksPath .githooks`) + `.cursor/hooks.json`; subagents in `.claude/agents/`.

## Quick reference

| Need | Go to |
|---|---|
| Product thesis | `VISION.md` |
| How it works | `docs/architecture.md` |
| Active plan + gates | `plans/` |
| Git / CI / review workflow | `docs/git-workflow.md` |
| What shipped | `docs/status.md` |
| Decisions expensive to reverse | `DECISIONS.md` |
