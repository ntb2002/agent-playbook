# The Agent Playbook

> A portfolio-wide standard for building software with AI coding agents (Cursor, Claude Code, their cloud agents, and the coordinators that run them) — designed for a founder who orchestrates multiple agents across multiple ventures and reviews from a phone.
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
- When work becomes active, a **strong model expands it into gated, session-sized units and stops**. A human reviews and approves before any execution agent builds. The planning agent's only deliverable is the plan. That review gate is where your judgment adds the most value.
- **Match ceremony to maturity here too:** fully expand only the *next* unit; leave later units as roadmap bullets until they're up next.
- **Two organizing units, same doctrine** (see *Phase mode and continuous mode* below): pre-v1 work is organized by **phase** (`/plan-phase` → `plans/<phase>/`); once a product is live, work is organized by **issue** (`/plan-feature <issue>` → `plans/features/<issue>.md`) and the tracker owns *what's next*. The repo always owns *how it works*.

### 4. Verification gates must be mechanically checkable from a phone

Every plan unit ends with a gate. Each gate item is tagged by evidence tier so review is fast and confident, not a deep read:

- **`[CI]`** — a green check proves it (lint, tests, build). Best tier; aim for this. Only tag `[CI]` if the check actually exists.
- **`[ARTIFACT]`** — a screenshot, recording, log, or curl output attached to the PR proves it. Includes agent-captured evidence — build/test output or preview renders via local tools (e.g. Xcode MCP). Only tag `[ARTIFACT]` if a tool can actually produce that evidence.
- **`[MANUAL]`** — hands-on verification an agent genuinely can't do (physical device, real payments/push, interactive tap-through flows, subjective feel); spell out the exact steps + expected result.

A unit is done only when every gate item is checked with evidence attached to the PR.

This rule binds **every** agent in the system, including coordinators and supervisors (below). A coordinator that reports "done" without the evidence on the PR has failed the gate exactly as an execution agent would. Frontier agents still resolve well under half of real production tasks unsupervised — the evidence tiers are what make delegation safe, not the model.

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

This extends to coordinators: a Cursor Project accumulates "shared context" as it works. That is working memory, not the record. Decisions still land in `DECISIONS.md`; conventions still land in `AGENTS.md`; what shipped still lands in `docs/status.md`. If a coordinator learns something durable, it writes it to the repo file that owns it.

---

## Phase mode and continuous mode

The playbook's original `plans/phase-N/` layout encodes a **launch model**: work converges on a v1. That's correct pre-revenue and wrong afterward — a shipping product has an ever-evolving backlog, not five phases and then perfection. Both modes use the same doctrine (in-repo gated specs, human approval, one unit = one PR); they differ in the organizing unit and in who owns *what's next*.

| | Phase mode | Continuous mode |
|---|---|---|
| **When** | Pre-v1: converging on something you can put in front of users | Post-launch: prioritized backlog, features, fixes, tweaks |
| **Organizing unit** | A phase → `plans/<phase>/README.md` + unit files | An issue → `plans/features/<issue-id>-<slug>.md` |
| **What's next lives in** | `AGENTS.md` phase table + `plans/<phase>/README.md` | The tracker (Linear); the landing pad just points at it |
| **Planning ritual** | `/plan-phase <phase>` | `/plan-feature <issue-id>` |
| **Branch name** | `<phase>/<unit>` | `<issue-id>-<slug>` (the tracker auto-links the PR) |
| **Done means** | Unit gate met, status + landing pad updated, PR open | Same, plus the tracker closes the issue on merge |

Treat phase mode as a *special case* of continuous mode for genuinely large subsystems, not as a predecessor era — the two rituals are siblings selected by size. A live product can still run a phase for a big build (e.g. a proactive-scheduling subsystem) while the tracker handles everything else.

**Three layers, one human seam:**

| Layer | Answers | Lives in | Who reads it |
|---|---|---|---|
| **Thinking** | What should exist, and why? | Knowledge layer: Notion hubs, Claude projects, chats | Humans only. **No coding agent reads this layer.** |
| **Seam** | What do we build next, and how do we know it's done? | The tracker (Linear): issues with acceptance criteria | Humans write; humans and agents read |
| **Code** | How does it work, and how is each unit proven? | The repo: `VISION.md`, `AGENTS.md`, `plans/`, gates | Agents and humans |

The thinking layer is deliberately sprawling — half-formed ideas, archived reasoning, business context. That's what makes it useless as agent input: an agent reading a hub page treats six months of prose as spec. The only channel from thinking to code is **a human writing acceptance criteria into the tracker**. That translation is the highest-leverage act in the loop; don't automate it and don't skip it. The one deliberate crossing is `VISION.md`: a one-page, code-facing distillation of the thesis that a human curates. If agents need more "why" than that page holds, the issue's acceptance criteria carry it.

**Tracker rules (seam rot prevention):**

- The tracker owns *what's next and who's on it*. The repo owns *how it works, conventions, plans, gates*. The knowledge layer owns *strategy and decisions-and-why*. One fact, one home — a venture hub page must **not** duplicate engineering status; it points at the tracker.
- Capture is cheap: any idea goes into tracker triage as one line, from anyone (including non-technical co-founders writing plain English). Filtering against `VISION.md`'s scope fence happens at prioritization, not at capture.
- Only big or ambiguous issues get a thinking doc. Most skip straight to acceptance criteria → `/plan-feature` → gated unit.
- **Coordinators never resolve product questions.** An ambiguous issue gets a question back to the human, not the coordinator's own judgment about what the product should do. Feasibility questions may flow the other way (ask the coordinator read-only, carry the answer back to the thinking layer). If implementation starts driving product definition, the seam has rotted.
- **Gates are written against the code, not against the idea.** A checklist drafted in the knowledge layer without reading the codebase is a proposal, not a gate. The gate is what an agent with the repo open turns it into — grounded in what the code does today and sized to the actual release (a one-user shakeout needs a different bar than a cohort launch).

---

## Automation primitives (and when to use each)

| Primitive | What it is | Use for |
|---|---|---|
| **Rules / memory** | Always-on context (`AGENTS.md`, `.cursor/rules/*.mdc`, `CLAUDE.md` with `@AGENTS.md`) | Conventions every agent must always follow |
| **Skills** | Parameterized, repeatable prompts (`.agents/skills/*/SKILL.md`) | Rituals: `/context-sync`, `/plan-phase`, `/start-unit`, `/close-unit` |
| **Subagents** | Specialized workers with restricted tools (`.claude/agents/*`, Cursor Task) | Scoped jobs, e.g. read-only `code-review` |
| **Hooks** | Deterministic shell on lifecycle events (`.githooks/`, `.cursor/hooks.json`) | Guarantees: secret-scan, lint/test on commit |
| **MCP** | Project-scoped tool servers (`.cursor/mcp.json`) | External integrations (DB, deploy, monitoring) — same in-repo, one-source-of-truth principle |
| **Automations** | Event- or schedule-triggered cloud agents (Cursor Automations; prompts kept in `.cursor/automations/`) | Unattended jobs: PR review on open, CI-failure triage, autofix review comments, staleness checks |
| **Coordinator** | A persistent agent that plans and delegates but never writes code (Cursor Project) | A body of work that outlives one chat: a tracker backlog, a migration, ongoing "gardening" of a repo |
| **Supervisor** | An agent that reads other agents' output and pushes back (Grok Bot, or you) | Verifying `[ARTIFACT]` evidence is real, nudging stalled work, escalating to a human |

Rule of thumb: if you'd repeat an instruction in every prompt, make it a **rule**. If it's a multi-step ritual, make it a **skill**. If it needs a guarantee, make it a **hook**. If it's a specialized recurring job, make it a **subagent**. If it's an external tool integration, wire it via **MCP**. If it should happen without you prompting, make it an **automation**. If it's a whole body of work, give it a **coordinator**. A stale automation is worse than none — refresh or delete.

**Coordinators and supervisors — the two rules that matter:**

1. **One coordinator per repo.** Two agents that both believe they own a repo's backlog is seam rot with extra steps. If a Cursor Project coordinates a venture's engineering, a personal ops agent (Grok Bot) does not dispatch coding agents to that repo directly — it files a tracker issue and the coordinator picks it up. Audit trail stays in one place.
2. **Coordinators read the playbook; they don't replace it.** Point every coordinator at `AGENTS.md`, this doctrine, and the repo's `docs/coordinator.md` brief on creation. It pulls the next tracker issue, expands it into a gated unit (`/plan-feature`), dispatches an execution agent, watches the PR to green, and reports with evidence. It never merges. Start by reviewing every PR it produces; loosen only as gates hold.

**Notes on the cloud environment:** `.cursor/environment.json`'s `install` step is what Cursor's *Builds* pre-bake, so anything that can be prepared ahead of time (deps, hook enable) belongs there — agents then boot into a warm environment. `.cursor/hooks.json` fires in cloud agents as well as locally, so the commit guard travels.

---

## Orchestration model (laptop + phone)

```
   thinking layer (Notion, Claude projects) ── you write acceptance criteria ──┐   (humans only; off the loop)
                                                                              ▼
        (tracker)                 (coordinator)                  (execution agents)
   Linear: what's next,   ──►  Cursor Project: pulls    ──►  cloud agent builds one gated
   acceptance criteria,        issue, /plan-feature,          unit on a branch, pushes,
   triage (anyone files)       dispatches, watches PR         opens PR
        ▲                              │                              │
        │                              │                  CI runs (+ hook ran in cloud)
   issue closes on merge               │                              │
        ▲                              ▼                              ▼
   (you, on a phone) ◄─ merge ◄─ review evidence ◄─ Automation reviews PR ◄─ PR open ◄─┘
                                    ▲
                      supervisor (Grok Bot / you) checks [ARTIFACT] is real, pings you
```

The thinking layer is above the loop, not in it: coding agents never read it, and the arrow out of it is a human. Pre-v1 projects run the same loop without the tracker/coordinator columns: you pick the unit, an agent builds it, you review on your phone.

- **Thinking layer (Notion, Claude projects, chats)** — product and business thinking, feature brainstorming, decisions-and-why, the non-code pillars. Off the loop by design. Its outputs reach code only as human-written acceptance criteria in the tracker and the hand-curated `VISION.md`.
- **Linear** — the backlog and the delegation surface. Assigning an issue to Cursor spins up a cloud agent that returns a PR; `@Cursor` in a comment adds instructions. Issue status flows from PR state via the GitHub integration.
- **Cursor Project (one per venture repo)** — the coordinator. Holds context across months, delegates to subagents on isolated VMs, subscribes to its own PRs (fixes CI, addresses bot comments), can watch a Slack channel or run on a schedule. Never writes code, never merges, never decides what the product should do — "should we build X?" belongs in the thinking layer; "is X feasible in the current code?" is a fair read-only question to ask it.
- **Cursor Automations** — unattended PR review, CI-failure triage, autofix of review comments, staleness checks. Starter prompts in `templates/.cursor/automations/`.
- **Cursor iOS app** — launch and steer cloud agents, review diffs and artifacts, merge PRs. Remote Control hands a laptop agent off to your phone.
- **Slack** — notifications (PR opened, CI pass/fail, automation summaries) + launching cloud agents by message.
- **GitHub mobile** — the review surface: diff, CI check, gate checklist, merge.
- **Grok Bot** — supervisor and ops agent, not a coder. Acts in tools with no API; can read cloud-agent transcripts and artifacts and push back when evidence doesn't match the claim. Its state is tied to the account — durable facts still go to the repo and the knowledge layer.
- **Laptop / Cursor** — interactive work; ambiguous or cross-cutting units you drive yourself with the strongest model.
- **Claude Code** — same git flow; `CLAUDE.md` imports `AGENTS.md` via `@AGENTS.md`. Best surface for messy, high-context debugging.
- **Xcode (iOS projects)** — specialist surface: native agent for SwiftUI previews, simulator work, and crash-report-driven fixes; its MCP server (`xcrun mcpbridge`) gives Cursor/Claude Code a real build-test-preview loop. Local-only today; a self-hosted Mac worker would let cloud agents produce iOS `[ARTIFACT]` evidence. Setup in `templates/SETUP.md`.

Per-project setup checklist (including the *venture cell* — everything a new venture needs beyond the repo) lives in `templates/SETUP.md`.

---

## How to use this playbook

1. **New project:** run `./bootstrap.sh <path> "<Project Name>" "<one-liner>"`. It scaffolds the docs + automation, parameterizes placeholders, and prints the maturity-ladder enable steps.
2. **Existing project:** copy the relevant `templates/` files in, fill placeholders, and adopt incrementally (start with `VISION.md` + `AGENTS.md`, add CI + hooks when it can break). `./sync.sh <repo>` refreshes the ritual layer later.
3. **Going live:** switch to continuous mode — set up the tracker and the coordinator per `templates/SETUP.md`, and flip the landing pad to point at the tracker.
4. **Evolving the standard:** SmartSport is the proving ground. When a practice proves out there, generalize it back into these templates + this doctrine. Update `PLAYBOOK.md` first, then the templates.
