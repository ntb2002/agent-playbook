# The Agent Playbook

> A portfolio-wide standard for building software with AI coding agents (Cursor, Claude Code, their cloud agents, and the coordinators that run them) — designed for a founder who orchestrates multiple agents across multiple ventures and reviews from a phone.
>
> This is the **doctrine**. The [`templates/`](templates/) are the copy-ready files; [`bootstrap.sh`](bootstrap.sh) scaffolds a new project from them. NOVA is the reference implementation once it has code; SmartSport (`~/Developer/smartSportApp`, paused) is the sandbox where workflow experiments run first. Rationale for every doctrine change is in [`CHANGELOG.md`](CHANGELOG.md); open problems are in [`FRICTION.md`](FRICTION.md).

---

## Why this exists

Running several agents across several projects breaks down without a shared standard. Three failure modes this prevents:

1. **Context rot** — critical rules buried under transient status; stale docs that actively mislead agents.
2. **Plans that don't travel** — work plans stuck in one tool on one machine, invisible to cloud agents and other devices.
3. **Unreviewable output** — agents producing changes you can't verify quickly or confidently, especially from a phone.

The fix is a small set of principles applied consistently, with the heavy machinery (coordinator, automations, bot reviewer) turned on by trigger when a project actually needs it — never by default.

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
| `plans/` | Deep-lane unit specs (open ones only) + optional project design notes | per Deep-lane unit |
| `docs/status.md` | changelog / what shipped, open technical threads | every session |
| `DECISIONS.md` | decisions expensive to reverse | when one is made |

What's next does not live in the repo at all — it lives in the tracker (see *Organizing work*).

`AGENTS.md` is the **constitution** and stays lean (target < 250 lines). It opens with a **landing pad** — a 30-second "where am I / what next" — because the #1 thing an agent (or you) needs is current state and the next action.

### 2. Match ceremony to maturity

Never impose the full apparatus on a throwaway. A system that's too heavy won't get used. But the *loop* — issue → branch → PR with evidence → human merge — is not the heavy part; it is the playbook. What gets earned is the repo hardening and the machinery around the loop.

| Tier | What it gets |
|---|---|
| **Below the line** — throwaway scripts, one-evening experiments, things you won't come back to | `AGENTS.md` only. No tracker, no PRs, commits to `main`. Conventions, not a loop. Outside the rituals. |
| **On the playbook** — anything you will return to, from day one | `VISION.md`, `AGENTS.md`, a **declared tracker** (Linear or GitHub Issues — see *Organizing work*), the rituals, branch → PR, pre-commit hook, `DECISIONS.md`. The loop, from the first commit. |
| **Can break** — real codebase, other people can pull it | + **CI**, branch protection, secret scanning / push protection, `plans/` Deep-lane specs. |
| **Real users / prod deploys** | + staging environment, dedicated secret scanning in CI, platform CI. |

Coordinator, automations, and bot reviewer are **not** on this ladder. They turn on by trigger, not by stage — see *Earned machinery* under *Automation primitives*. The full template ships everything; you enable hardening as the project earns it and machinery when a trigger fires.

### 3. Plans live in-repo and are reviewed deliverables

- The **issue is the spec** for Standard- and Fast-lane work: acceptance criteria and an evidence-tagged gate live in the tracker issue's description. Only **Deep-lane** units get a repo plan file, `plans/features/<issue-id>-<slug>.md`, written by `/plan-feature` and deleted by `/close-unit` in the PR that ships it. Plan files live **in the repo**, not in `~/.cursor/plans/` or a tool's todo list, so they travel to every clone, device, and cloud VM. Tool-native plan modes (Cursor `.plan.md`, Claude Code todos) are **ephemeral scratch**.
- When a body of work becomes active, a **strong model decomposes it into session-sized issues and stops**. `/plan-phase <project>` is that decomposition: one strong-model plan amortized across many cheap-model units. Its output is issues in the tracker project, not a folder. A human accepts and promotes them before any execution agent builds. That review gate is where your judgment adds the most value.
- **Fully specify only the next unit or two.** A greenfield decomposition is wrong by the fourth unit — once the data model lands, the criteria you wrote for the viewport are stale. `/plan-phase` writes full acceptance criteria and a gate for the first one or two issues and leaves the rest **thin**: title, one-line intent, milestone, `blocked by` links. Thin issues get their criteria when they approach Todo, by an agent reading the code as it exists then. Over-specified issues are worse than over-specified plan files, because agents treat issue text as the spec.
- **One organizing unit: the issue.** A phase is a tracker project; a feature is an issue until it needs several. The tracker owns *what's next*; the repo owns *how it works*. `plans/` is never a work queue — see *Organizing work*.

### 4. Verification gates must be mechanically checkable from a phone

Every plan unit ends with a gate. Each gate item is tagged by evidence tier so review is fast and confident, not a deep read:

- **`[CI]`** — a green check proves it (lint, tests, build). Best tier; aim for this. Only tag `[CI]` if the check actually exists.
- **`[ARTIFACT]`** — a screenshot, recording, log, or curl output the reviewer can open from the PR or tracker issue proves it. Includes agent-captured evidence — build/test output, preview renders, simulator screenshots from a driven flow, console/debugger output via local tools (e.g. Xcode 27 MCP), browser recordings from a cloud agent's VM. Only tag `[ARTIFACT]` if a tool the agent actually has can produce that evidence — check, don't assume; tool surfaces change between versions. Placement matters as much as capture: on a private repo, images embedded in a PR body from the repo don't render; local-lane evidence is committed and *linked*, cloud-lane evidence rides Cursor's artifact pipeline. `templates/plans/README.md` has the table.
- **`[MANUAL]`** — hands-on verification an agent genuinely can't do (physical-device-only behavior, real payments/push, subjective feel); spell out the exact steps + expected result.

A unit is done only when every gate item is checked with evidence attached to the PR.

This rule binds **every** agent in the system, including coordinators and supervisors (below). A coordinator that reports "done" without the evidence on the PR has failed the gate exactly as an execution agent would. Frontier agents still resolve well under half of real production tasks unsupervised — the evidence tiers are what make delegation safe, not the model.

### 5. One model/tool policy, not per-task improvisation

- **Planning / architecture / expensive-to-reverse decisions** → strongest model, high reasoning.
- **Ambiguous or cross-cutting execution** (schema, auth, multi-system refactors) and **gnarly debugging** → strongest model too — decision quality during execution matters more than spec quality there.
- **Executing a well-specified unit** → fast/mid model. The spec quality sets the model floor: a tight issue is what makes cheap execution safe (this is the economic function of `/plan-phase` — one strong-model decomposition amortized across many cheap-model units).
- **Mechanical edits** → fast model.
- **Cheap classification / in-session helpers** → smallest model.
- **Escalate on first failure:** if a cheap model whiffs a unit once, hand it to the strong model — don't re-prompt the same tier. Two failed cheap runs plus review time cost more than one strong run.
- **Parallelize only independent units** (neither's dependency includes the other), and only within the WIP limit (*Organizing work*). Dependent units run serially: build → verify gate → update status + landing pad → PR → next.
- **Route by tier, not by tool loyalty.** Cursor and Claude Code are both primary drivers; the tier picks the surface. `fast` / `mid` → Cursor (execution, phone remote, tracker → cloud-agent delegation). `strong` → Claude Code on the strongest Claude model, starting at medium effort and raising it only when medium visibly falls short. Codex → overflow execution and second-opinion review only; not structural. **Planning tokens are the expensive ones** — do planning where the budget resets often (Claude Code session limits) rather than on monthly-capped credits. The concrete model names live in `templates/.cursor/rules/model-policy.mdc`, date-stamped, because they rot.

### 6. `main` is sacred; everything flows through a reviewed, CI-green PR

One issue = one branch (`<issue-id>-<slug>`) = one PR. Never commit to `main` (it's what deploys). Two gate layers: a **local pre-commit hook** (fast, bypassable courtesy) and **CI on the PR** (authoritative, server-side, can be *required*). Trust CI, not the hook. Full model in the `docs/git-workflow.md` template.

### 7. One source of truth across tools

`AGENTS.md` is the single source of truth for conventions. Cursor reads it natively; Claude Code imports it via `CLAUDE.md` (`@AGENTS.md` as the first line). Don't keep agent-private state in one tool's config that another can't see. **One fact, one home.**

This extends to coordinators: a Cursor Project accumulates "shared context" as it works. That is working memory, not the record. Decisions still land in `DECISIONS.md`; conventions still land in `AGENTS.md`; what shipped still lands in `docs/status.md`. If a coordinator learns something durable, it writes it to the repo file that owns it.

---

## Organizing work

All work is organized by issue from the first commit. There is one mode. A pre-v1 build and a live product's backlog run the same loop; what differs is how much is in Triage.

**A phase is a project.** A large body of work converging on an outcome ("NOVA MVP") is a **tracker project**, optionally with milestones. `/plan-phase <project>` decomposes it into session-sized issues filed into that project (the first one or two fully specified, the rest thin — *principle 3*), never moves status, and stops. `plans/<project>/README.md` may hold phase-level design that doesn't fit an issue — an architecture sketch, sequencing rationale. It is optional and it is not a queue.

### The tracker is declared per repo

Every repo on the playbook names its tracker in the `AGENTS.md` landing pad. Two are sanctioned:

| Tracker | Use when | What it gives you |
|---|---|---|
| **Linear** | The work has stakeholders beyond you: a co-founder who needs to see and file work, a Notion thinking layer that needs a seam into code, projects and milestones on a timeline, tracker-driven agent delegation. In practice: ventures. | Triage / Backlog / Todo as real states, projects, milestones, timeline, Linear Agent, `@Cursor` delegation from an issue, Linear MCP in every coding surface. One team per venture, **subject to plan limits** — the free tier is two teams, so a third venture means upgrading or using the GitHub tier. |
| **GitHub Issues** | Solo repos, tools, MCP servers, open source — anything where you are the only stakeholder. | Same playbook, same rituals, lanes, gates, and PR flow; GitHub mobile is already the review surface; `Closes #12` closes the issue on merge; agents read issues with `gh issue view`, no MCP required. State mapping: open + unlabeled = Triage, `accepted` label = Backlog, `ready` label = Todo. Milestones stay reserved for user-visible checkpoints. |

**Issues live in the repo's declared tracker.** Agents never search anywhere else for work — not the other tracker, not Notion, not `plans/` — and an issue never exists in two places. `/start-unit` fails loudly if it cannot fetch the issue; it does not guess from a plan file. Below the line (*principle 2*) there is no tracker and no loop.

### What each thing is

| Object | Lives in | Is |
|---|---|---|
| **Weekly Goal** | Notion (thinking layer) | An outcome for the week, with a *why* if it slips. Never in the tracker. |
| **Project** | Tracker | A body of work toward an outcome ("NOVA MVP"). A phase is a project. |
| **Milestone** | Tracker (optional) | A user-visible capability checkpoint inside a project ("viewport renders a model") — not a technical layer. |
| **Issue** | Tracker | **A session-sized unit of work.** The only thing agents build. One issue = one branch = one PR. |
| **Feature / Bug / Improvement** | Tracker labels | Labels on an issue, not separate objects: new capability / broken existing behavior / better existing behavior. |

- **An issue is a session of work, not a change.** Work *in scope* of the issue you are building is a commit inside its PR, never a new issue. Work *out of scope* is a Fast-lane issue if you are fixing it now, or a one-line Triage capture if you are not. This is the same sentence as the Fast lane's boundary.
- **Polish is captured, not accumulated.** One "polish" issue per project collects bullets in Backlog. When it is picked, it is worked as a normal single-session issue — one branch, one PR — and closed. A polish issue is never open across multiple PRs.
- **Sub-issues only when each child is itself session-sized.** Otherwise it is one issue.
- **A feature starts as one Triage issue.** It becomes a project only when it needs several issues, milestones, or a timeline.

### Where ideas live (the graduation path)

| State of the idea | Home |
|---|---|
| Could be valuable someday; vision, research, rationale | Notion |
| We might build this | Tracker **Triage** (plain English is fine; co-founders write here) |
| We intend to build it, not now | Tracker **Backlog** |
| We're organizing toward this outcome | Tracker **project** + timeline |
| We're building it next | Tracker **Todo** (+ a repo plan file only if Deep lane) |

Links, never copies: a tracker project links its Notion hub; a Notion hub links the active project and never restates delivery status.

**Status ownership, precisely:** the tracker owns scheduling and delivery state — what's next, what's in progress, what's done, who's on it. Notion links to it and never restates it. The repo keeps the **code-side history**: `docs/status.md` records what shipped and open *technical* threads; the `AGENTS.md` landing pad says where the code is and points at the active project. `/context-sync` maintains both. Neither repo doc is a queue.

### WIP limit

- **One issue being built per repo at a time** — one branch with active work on it, whether a human or an agent is driving — plus at most one read-only investigation.
- PRs that are open and awaiting review do **not** count. The tracker holds them In Progress until merge; that is automation, not work in flight. Ship the next unit; merge from the phone when you get to it.
- Independent units delegated to cloud agents are the one exception, and only when a coordinator exists to own them. Without a coordinator, WIP is one.
- Todo stays small. It is what is genuinely next, not a second backlog.
- Why: a solo founder across several ventures. Switching cost should be visible, not hidden in parallel branches.

**Three layers, one approval gate:**

| Layer | Answers | Lives in | Who writes / who reads |
|---|---|---|---|
| **Thinking** | What should exist, and why? | Knowledge layer: Notion hubs, Claude projects, chats | Humans and thinking agents write. **Execution agents never read it.** |
| **Seam** | What do we build next, and how do we know it's done? | The tracker (Linear, or GitHub Issues on the solo tier): issues with acceptance criteria | Anyone writes — humans, thinking agents, coordinators, execution agents. **A human approves what enters the build queue.** |
| **Code** | How does it work, and how is each unit proven? | The repo: `VISION.md`, `AGENTS.md`, `plans/`, gates | Agents and humans |

The thinking layer is deliberately sprawling — half-formed ideas, archived reasoning, business context. That's what makes it useless as *execution* input: a coding agent reading a hub page treats six months of prose as spec. Ideas reach code through the tracker, as issues with acceptance criteria — and **drafting those is agent work**, exactly as `/plan-phase` has always drafted units and gates from a human's phase intent. What stays human is the approval: an issue leaves Triage only when a person accepts it, enters the build queue (Todo) only when a person promotes it, and a plan unit is built only after a person approves it. Two deliberate crossings from thinking to code: `VISION.md`, a one-page code-facing distillation of the thesis that a human curates; and the acceptance criteria themselves, which may be drafted anywhere (a Claude project with the Linear connector, Grok Bot from a voice note, the coordinator from a one-line capture) but are approved in the tracker.

**Tracker rules (seam rot prevention):**

- The tracker owns *what's next and who's on it*. The repo owns *how it works, conventions, plans, gates*. The knowledge layer owns *strategy and decisions-and-why*. One fact, one home — a venture hub page must **not** duplicate engineering status; it points at the tracker.
- **Issues live in the declared tracker.** `/start-unit SP-7` means fetch `SP-7` from the tracker the landing pad names — not search the other tracker, Notion, or `plans/` for a ticket. `plans/features/` is the Deep-lane execution spec written *after* `/plan-feature` for an already-accepted issue — it is not where agents look to discover work.
- **No meaningful code change merges without an issue.** The only exceptions are disposable experiments that will not be merged, and pure mechanical fixes (typos, copy) — and the second still gets a Fast-lane issue if it gets a PR.
- Capture is cheap: any idea goes into tracker triage as one line, from anyone (including non-technical co-founders writing plain English). Filtering against `VISION.md`'s scope fence happens at prioritization, not at capture.
- **Titles name the work.** The identifier (`SP-21`), project, labels, priority, and estimate are structured fields — do not copy them into the title. No plan-file codes (`TR-00 ·`), no gate numbers, no team prefix. If a mapping from a planning doc is useful, it lives in the description or a table in the plan file.
- **Agents work the tracker.** Expand one-line captures into draft acceptance criteria (posted on the issue, marked as draft), decompose projects into issues, dedupe/label/estimate/link, file follow-ups and bugs found mid-unit, post progress and PR links. Use the tracker's agent integrations for all of it. What an agent never does is change an issue's status by hand: it doesn't accept out of Triage and it doesn't promote into Todo. Status moves by human click or by PR automation (In Progress on open, Done on merge). **This includes agents in a chat with the human.** "You approved the plan this came from," "you said it sounds good," "you'd obviously want this" — none of those are the click. If an agent thinks a batch of issues is ready to leave Triage, it says so and lists them; the human presses the key. Two exceptions: undoing an agent's own mistake (e.g. a PR title wrongly moved issues to In Progress) — put things back, then stop; and the **fast lane** below, where the human approved the specific work in the same conversation, so the agent files the issue straight into In Progress as the record.
- **Three states, two human clicks.** *Triage* is the inbox — everything agents, integrations, and non-team members create lands there, and it should trend toward empty. *Backlog* is "approved in principle, not scheduled." *Todo* is the build queue: approved *and* specified, the only place execution agents and coordinators pull from. A human **accepts** an issue out of Triage (into Backlog, or straight to Todo if it's ready and next) and **promotes** it into Todo. Triage is not a backlog; if it fills up, the human has stopped reviewing, not the agents.
- **Product questions live in `## Needs human`, answers land as a comment, then get folded into the description.** Agents drafting an issue put open product calls under that heading (numbered, with a recommendation). A human replies in a *comment* — one line per item is enough; do not rewrite the issue by hand, and do not put the decision only in a `/plan-feature` prompt (that dies with the chat). An issue may sit in Backlog with `## Needs human` open; before it enters Todo, an agent (or the human) replaces `## Needs human` with `## Decided`, writes the answers into the spec, and comments that they folded. `/plan-feature` treats an issue that still has `## Needs human` as underspecified and stops. The comment is the audit trail; the description is what execution reads.
- **Proportional rigor — three lanes.** Ceremony scales with risk; the proof never does. Every lane keeps the non-negotiables: a tracker issue as the record, a branch, a PR titled with the issue id, and gate evidence (test + artifact) on the PR. What varies is how much approval and planning sits in front of the build:

  | Lane | When | Path |
  |---|---|---|
  | **Fast** | Cause already understood, small diff, no schema / auth / user-facing prompts / `DECISIONS.md` call — typically a bug found and diagnosed while pairing with a code agent, and **out of scope** of the issue currently being built (in-scope work is a commit, not an issue) | Human says "go" in chat → agent files the issue (into In Progress, with repro + cause + gate) → branch → fix + test + evidence → PR. No Triage round-trip, no plan file. |
  | **Standard** | A clear, specified issue in Todo | `/start-unit` → build → `/close-unit`. The issue *is* the spec; no plan file. |
  | **Deep** | Ambiguous, risky, cross-cutting, `strong` tier, or anything touching prompts, safety, schema, or auth | `/plan-feature` → human reviews the plan → `/start-unit` → `/close-unit`. |

  When unsure, go one lane deeper. If a fast-lane fix grows (the diff spreads, or a product question appears), stop and move it to Standard or Deep.
- **Who shapes an issue depends on what they can see.** A tracker agent without code access (e.g. Linear Agent) shapes the *product* side — problem, impact, acceptance criteria, `## Needs human` — and never guesses root causes or implementation. A code-aware agent shapes the *technical* side: investigates, posts findings on the issue, and writes the plan when the Deep lane needs one. Two bug intake paths follow from this:
  - **Found while coding** (pairing with Claude Code or Cursor): the Fast lane. The coding agent already has the repro and the cause, so it files the issue itself and fixes it. Don't route it through a tracker agent.
  - **Found while using the app** (phone, away from the laptop): capture a one-line issue in Triage. A tracker agent may shape the product side only. A code-aware agent investigates **read-only** and posts findings on the issue before anyone plans a fix.
- Only big or ambiguous issues get a thinking doc.
- **Coordinators never resolve product questions.** An underspecified issue gets *draft* criteria plus a question back to the human — not the coordinator's own decision about what the product should do. Feasibility questions may flow the other way (ask the coordinator read-only, carry the answer back to the thinking layer). If implementation starts driving product definition, the seam has rotted.
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

**Earned machinery.** A new project starts with all three of these **off**. Each turns on when its trigger fires — not when the product launches, not because the template ships it:

| Machinery | Turn on when |
|---|---|
| **Coordinator** (Cursor Project) | Todo regularly holds more ready issues than you can hold in your head, or you're delegating several issues a week to cloud agents. |
| **Automations** | A manual ritual has run the same way ~5 times and you're re-typing the same prompt. |
| **Bot reviewer** (Bugbot / Grok Bot) | PR volume means you're skimming reviews instead of reading them. |

Until then: tracker + rituals + you. That is the whole system for most of a project's life, and it is enough.

**Notes on the cloud environment:** `.cursor/environment.json`'s `install` step is what Cursor's *Builds* pre-bake, so anything that can be prepared ahead of time (deps, hook enable) belongs there — agents then boot into a warm environment. `.cursor/hooks.json` fires in cloud agents as well as locally, so the commit guard travels.

---

## Orchestration model (laptop + phone)

```
   thinking layer (Notion, Claude projects, Grok Bot) ── issues drafted by anyone ──┐   (execution agents never read it)
                                                          human approves ──────────┤
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

The thinking layer is above the loop, not in it: execution agents never read it. Issues can be drafted from it by anyone — you, a co-founder, a Claude project, Grok Bot — but the arrow into the build queue is a human approval. Before the coordinator trigger fires, the middle column is you: you pick the Todo issue, an agent builds it, you review on your phone. The tracker column is there from the first commit.

- **Thinking layer (Notion, Claude projects, chats)** — product and business thinking, feature brainstorming, decisions-and-why, the non-code pillars. Off the loop by design. Its outputs reach code as tracker issues (drafted by humans or agents, approved by a human) and the hand-curated `VISION.md`.
- **The tracker** — the backlog and, on Linear, the delegation surface. Assigning a Linear issue to Cursor spins up a cloud agent that returns a PR; `@Cursor` in a comment adds instructions. Issue status flows from PR state via the GitHub integration (Linear) or `Closes #n` (GitHub Issues).
- **Cursor Project (one per venture repo)** — the coordinator. Holds context across months, delegates to subagents on isolated VMs, subscribes to its own PRs (fixes CI, addresses bot comments), can watch a Slack channel or run on a schedule. Never writes code, never merges, never decides what the product should do — "should we build X?" belongs in the thinking layer; "is X feasible in the current code?" is a fair read-only question to ask it.
- **Cursor Automations** — unattended PR review, CI-failure triage, autofix of review comments, staleness checks. Starter prompts in `templates/.cursor/automations/`.
- **Cursor iOS app** — launch and steer cloud agents, review diffs and artifacts, merge PRs. Remote Control hands a laptop agent off to your phone.
- **Slack** — notifications (PR opened, CI pass/fail, automation summaries) + launching cloud agents by message.
- **GitHub mobile** — the review surface: diff, CI check, gate checklist, merge.
- **Grok Bot** — supervisor and ops agent, not a coder. Acts in tools with no API; can read cloud-agent transcripts and artifacts and push back when evidence doesn't match the claim. Its state is tied to the account — durable facts still go to the repo and the knowledge layer.
- **Laptop / Cursor** — interactive work; ambiguous or cross-cutting units you drive yourself with the strongest model.
- **Claude Code (CLI + desktop app)** — same git flow and rituals: `CLAUDE.md` imports `AGENTS.md` via `@AGENTS.md`, `.claude/skills` symlinks the shared skills, `.mcp.json` carries project MCP servers (iOS overlay: Xcode). Best surface for messy, high-context work — debugging, prompt/product-quality passes, strong-tier units. The desktop app adds things Cursor lacks: an embedded **iOS Simulator panel** (live view you can watch and touch, plus headless screenshot/tap/inspect for the agent — a second `[ARTIFACT]` path beside Xcode MCP `DeviceInteraction*`), a built-in browser pane, and its own Remote Control / cloud sessions for steering a local session from the phone.
- **Xcode (iOS projects)** — its MCP server (`xcrun mcpbridge`) gives Cursor/Claude Code the full loop on Xcode 27: build, test, preview render, run with console, LLDB, drive the simulator and screenshot it, read field crashes. Local-only, so it backs `[ARTIFACT]`, never `[CI]`. The tools count only if they appear in **this chat's** live catalog — descriptors cached on disk from a previous Xcode session do not attach to a cloud worker or to a Remote Control worker that never inherited the server. Headless mode plus a Cursor Remote Control session on an always-on Mac is how iOS evidence gets produced from a phone. Xcode's native agent is a specialist surface, not the daily driver. Setup in `templates/SETUP.md`.
- **Remote Control (Cursor; Claude Code desktop has the equivalent)** — a local agent on your own Mac, steered from the phone/web; tool calls run against local files with local tools (Xcode, simulators, project MCPs, secrets). Same tokens as any agent; the win is capability, not cost. This is **not** a Linear `@Cursor` cloud agent (that worker has no Xcode MCP, ever). **It inherits the chat you started `/remote-control` in** — workspace root, project-scoped `.cursor/mcp.json`, secrets, everything. A playbook or ops chat will not grow Xcode tools because Xcode is sitting open; those tools live on the iOS repo's MCP. Start Remote Control from the venture chat when the gate needs simulator taps. Requires an awake, logged-in, Git-backed Mac whose **WindowServer is up** — lid closed with an external display and power (true clamshell) is fine; lid closed with no display sleeps the GUI and Device Interaction will not attach. The *local lane* for units whose gate needs local evidence; the *cloud lane* (Linear → cloud agent) for everything CI can prove. A playbook agent stays in the playbook repo; it does not hop the Cursor workspace into a venture to "just finish the unit."

Per-project setup checklist (including the *venture cell* — everything a new venture needs beyond the repo) lives in `templates/SETUP.md`.

---

## How to use this playbook

1. **New project:** run `./bootstrap.sh <path> "<Project Name>" "<one-liner>" [--tracker linear|github] [--ios]`. It scaffolds the docs + automation, parameterizes placeholders, and prints the human steps for the chosen tracker. The tracker is set up at bootstrap, not later.
2. **Existing project:** copy the relevant `templates/` files in, fill placeholders, declare the tracker in the landing pad, and adopt incrementally (add CI + branch protection when it can break). `./sync.sh <repo>` refreshes the ritual layer later.
3. **Earning the machinery:** turn on the coordinator, automations, and bot reviewer one at a time, each when its trigger fires (*Earned machinery*). `templates/SETUP.md` has the steps; they are optional sections, not a launch checklist.
4. **Evolving the standard.** **NOVA is the reference implementation** once it has code — the trial for this doctrine. **SmartSport is paused** (Sept 2026, until the NOVA MVP ships) and is the **sandbox**: workflow experiments run there before they reach NOVA. Experiments test workflow, never features; if the output of an experiment is a SmartSport feature, it wasn't an experiment. When a practice proves out, generalize it into this doctrine first, then the templates.

### The playbook steward

- **One writer.** A single Claude Code agent (strong tier), launched inside this repo, is the steward and the only writer of doctrine and templates. Cursor threads and venture agents that hit playbook friction — including a Cursor-specific fact in the doctrine that turns out to be wrong — log the exact correction in `FRICTION.md`; they do not edit doctrine. The steward verifies and writes it. One writer, no exceptions.
- **Direction comes from Nathan + Chief of Staff.** The steward turns decisions into doctrine text and templates, maintains the friction log, and pushes back when a decision has an implementation problem. It does not set strategy.
- **Memory lives in the repo, not in chat.** Doctrine in `PLAYBOOK.md`; rationale in `CHANGELOG.md` (date + decision + why, one entry per merged doctrine change); open problems in `FRICTION.md` (append-only; reviewed with the Chief of Staff every two weeks; the steward proposes, Nathan decides).
- **Doctrine changes are PRs.** Branch, PR, Nathan merges. Doctrine PRs never sync into a venture; `sync.sh` is a separate, reviewed step in the venture's own repo.
