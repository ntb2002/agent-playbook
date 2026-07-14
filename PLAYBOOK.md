# The Agent Playbook

> A portfolio-wide standard for building software with AI coding agents (Cursor, Claude Code, and their cloud agents) — designed for a solo builder who orchestrates multiple agents and reviews from a phone.
>
> This is the **doctrine**. The [`templates/`](templates/) are the copy-ready files; [`bootstrap.sh`](bootstrap.sh) scaffolds a new project from them. SmartSport (`~/Developer/smartSportApp`) is the live reference implementation.

---

## Why this exists

Running several agents across several projects breaks down without a shared standard. Three failure modes this prevents:

1. **Context rot** — critical rules buried under transient status; stale docs that actively mislead agents.
2. **Plans that don't travel** — work plans stuck in one tool on one machine, invisible to cloud agents and other devices.
3. **Unreviewable output** — agents producing changes you can't verify quickly or confidently, especially from a phone.

The fix is a small set of principles applied consistently, with the heavy machinery turned on only when a project is mature enough to need it.

---

## The seven principles

### 1. Separate context by volatility

Don't put slow-changing rules and fast-changing status in one file. Layer them so each doc changes at one rate:

| Doc | Holds | Changes |
|---|---|---|
| `VISION.md` | product thesis (what/why/who) | rarely |
| `AGENTS.md` | conventions + antipatterns + landing pad + roadmap index | slowly |
| `docs/architecture.md` | feature specs, data flows, contracts | slowly |
| `docs/git-workflow.md` | git/CI/review process | rarely |
| `plans/` | active roadmap + per-unit specs with gates | per active phase |
| `docs/status.md` | changelog / what shipped | every session |
| `DECISIONS.md` | decisions expensive to reverse | when one is made |

`AGENTS.md` is the **constitution** and stays lean (target < 250 lines). It opens with a **landing pad** — a 30-second "where am I / what next" — because the #1 thing an agent (or you) needs is current state and the next action.

### 2. Match ceremony to maturity

Never impose the full apparatus on an idea-phase project. A system that's too heavy won't get used.

| Stage | What it gets |
|---|---|
| **Idea / sketch** | `VISION.md` + a rough phase sketch. That's it. |
| **Prototype** | + `AGENTS.md` (conventions), a repo, maybe direct commits to `main`. |
| **Real codebase that can break** | + branch/PR discipline, pre-commit hook, **CI**, branch protection, `plans/` with gates, `DECISIONS.md`. |
| **Real users / prod deploys** | + bot reviewer on PRs, dedicated secret scanning, staging environment. |

The full template ships everything; you enable layers as the project earns them.

### 3. Plans live in-repo and are reviewed deliverables

- Plans live under `plans/` **in the repo**, not in `~/.cursor/plans/` or a tool's todo list. In-repo plans travel to every clone, device, and cloud VM. Tool-native plan modes (Cursor `.plan.md`, Claude Code todos) are **ephemeral scratch**.
- When a phase becomes active, a **strong model expands it into gated, session-sized units and stops**. A human reviews and approves before any execution agent builds. The planning agent's only deliverable is the plan. That review gate is where your judgment adds the most value.
- **Match ceremony to maturity here too:** fully expand only the *next* unit; leave later units as roadmap bullets until they're up next.

### 4. Verification gates must be mechanically checkable from a phone

Every plan unit ends with a gate. Each gate item is tagged by evidence tier so review is fast and confident, not a deep read:

- **`[CI]`** — a green check proves it (lint, tests, build). Best tier; aim for this. Only tag `[CI]` if the check actually exists.
- **`[ARTIFACT]`** — a screenshot, recording, log, or curl output attached to the PR proves it. Includes agent-captured evidence — build/test output or simulator screenshots via local tools (e.g. Xcode MCP).
- **`[MANUAL]`** — hands-on verification an agent genuinely can't do (physical device, real payments/push, subjective feel); spell out the exact steps + expected result.

A unit is done only when every gate item is checked with evidence attached to the PR.

### 5. One model/tool policy, not per-task improvisation

- **Planning / architecture / expensive-to-reverse decisions** → strongest model, high reasoning.
- **Ambiguous or cross-cutting execution** (schema, auth, multi-system refactors) and **gnarly debugging** → strongest model too — decision quality during execution matters more than spec quality there.
- **Executing a well-specified unit** → fast/mid model. The spec quality sets the model floor: a tight plan unit is what makes cheap execution safe (this is the economic function of `/plan-phase` — one strong-model plan amortized across many cheap-model units).
- **Mechanical edits** → fast model.
- **Cheap classification / in-session helpers** → smallest model.
- **Escalate on first failure:** if a cheap model whiffs a unit once, hand it to the strong model — don't re-prompt the same tier. Two failed cheap runs plus review time cost more than one strong run.
- **Parallelize only independent units** (neither's dependency includes the other). Dependent units run serially: build → verify gate → update status + landing pad → PR → next.

### 6. `main` is sacred; everything flows through a reviewed, CI-green PR

One plan unit = one branch = one PR. Never commit to `main` (it's what deploys). Two gate layers: a **local pre-commit hook** (fast, bypassable courtesy) and **CI on the PR** (authoritative, server-side, can be *required*). Trust CI, not the hook. Full model in the `docs/git-workflow.md` template.

### 7. One source of truth across tools

`AGENTS.md` is the single source of truth for conventions. Cursor reads it natively; Claude Code imports it via `CLAUDE.md` (`@AGENTS.md` as the first line). Don't keep agent-private state in one tool's config that another can't see. **One fact, one home.**

---

## Automation primitives (and when to use each)

| Primitive | What it is | Use for |
|---|---|---|
| **Rules / memory** | Always-on context (`AGENTS.md`, `.cursor/rules/*.mdc`, `CLAUDE.md` with `@AGENTS.md`) | Conventions every agent must always follow |
| **Skills** | Parameterized, repeatable prompts (`.agents/skills/*/SKILL.md`) | Rituals: `/context-sync`, `/plan-phase`, `/start-unit`, `/close-unit` |
| **Subagents** | Specialized workers with restricted tools (`.claude/agents/*`, Cursor Task) | Scoped jobs, e.g. read-only `code-review` |
| **Hooks** | Deterministic shell on lifecycle events (`.githooks/`, `.cursor/hooks.json`) | Guarantees: secret-scan, lint/test on commit |
| **MCP** | Project-scoped tool servers (`.cursor/mcp.json`) | External integrations (DB, deploy, monitoring) — same in-repo, one-source-of-truth principle |

Rule of thumb: if you'd repeat an instruction in every prompt, make it a **rule**. If it's a multi-step ritual, make it a **skill**. If it needs a guarantee, make it a **hook**. If it's a specialized recurring job, make it a **subagent**. If it's an external tool integration, wire it via **MCP**. A stale automation is worse than none — refresh or delete.

---

## Orchestration model (laptop + phone)

```
        (you, anywhere)                         (agents, on branches)
   pick the next plan unit  ───────────────►  agent implements unit on a branch
            ▲                                          │
            │                                  agent pushes + opens a PR
   merge the PR (phone or laptop)                      │
            ▲                                  CI runs (+ local hook ran)
            │                                          │
   review the PR  ◄── Slack ping ◄── GitHub ◄──────────┘
```

- **Slack** — notifications (PR opened, CI pass/fail) + launching cloud agents.
- **GitHub mobile** — the review surface: diff, CI check, gate checklist, merge.
- **Laptop / Cursor** — interactive work; cloud agents/worktrees for parallel independent units.
- **Claude Code** — same git flow; `CLAUDE.md` imports `AGENTS.md` via `@AGENTS.md`.
- **Xcode (iOS projects)** — specialist surface: native agent for SwiftUI previews, simulator work, and crash-report-driven fixes; its MCP server (`xcrun mcpbridge`) gives Cursor/Claude Code a real build-test-debug loop. Setup in `templates/SETUP.md`.

Per-project setup checklist lives in `templates/SETUP.md`.

---

## How to use this playbook

1. **New project:** run `./bootstrap.sh <path> "<Project Name>" "<one-liner>"`. It scaffolds the docs + automation, parameterizes placeholders, and prints the maturity-ladder enable steps.
2. **Existing project:** copy the relevant `templates/` files in, fill placeholders, and adopt incrementally (start with `VISION.md` + `AGENTS.md`, add CI + hooks when it can break).
3. **Evolving the standard:** SmartSport is the proving ground. When a practice proves out there, generalize it back into these templates + this doctrine. Update `PLAYBOOK.md` first, then the templates.
