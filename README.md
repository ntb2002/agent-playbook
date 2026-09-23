# agent-playbook

The operating standard for building software with AI coding agents across Nathan's ventures and tools. One loop, applied the same way in every repo, designed for a founder who orchestrates several agents and needs to be able to review from anywhere, phone included.

If you are new here — human or agent — read this file, then [`PLAYBOOK.md`](PLAYBOOK.md), then [`FRICTION.md`](FRICTION.md). That is the whole onboarding.

## The idea in one paragraph

Work is **issues** in a **tracker** (Linear for ventures, GitHub Issues for solo tools). An issue is a **session-sized** unit with acceptance criteria and an evidence-tagged **gate**. A human approves what enters the build queue; an agent builds exactly one issue on a branch named for it, gathers evidence, and opens a PR; the human reviews the evidence and merges (laptop or phone); the tracker closes the issue. Ceremony scales with risk (**Fast / Standard / Deep** lanes) but the proof never shrinks. Heavy machinery — a coordinator, automations, a bot reviewer — stays off until a trigger says you need it. The repo holds *how it works*; the tracker holds *what's next*; the thinking layer (Notion) holds *why*, and execution agents never read it.

## What's in this repo

| Path | What |
|---|---|
| [`PLAYBOOK.md`](PLAYBOOK.md) | The doctrine: seven principles, organizing work, tracker rules, lanes, automation primitives, orchestration roles. **The rules.** |
| [`docs/surfaces.md`](docs/surfaces.md) | Which product fills which role *this quarter*, with verified facts and gotchas. Dated and expected to rot. |
| [`CHANGELOG.md`](CHANGELOG.md) | Why each doctrine change was made. One entry per merged doctrine PR. The playbook's memory. |
| [`FRICTION.md`](FRICTION.md) | Append-only log of what was clunky or wrong in practice. Where changes come from. |
| [`templates/`](templates/) | Copy-ready files for a repo: `AGENTS.md` constitution, `VISION.md`, `DECISIONS.md`, `docs/`, `plans/`, CI, hooks, rules, skills, subagent, PR template, coordinator brief, automation prompts. |
| [`templates/SETUP.md`](templates/SETUP.md) | Per-project checklist: venture cell, tracker at bootstrap, GitHub hardening, cloud agents, earned machinery, phone orchestration, iOS. |
| [`overlays/`](overlays/) | Platform overlays layered by `bootstrap.sh` flags (`--ios`: Xcode MCP + iOS agent conventions). |
| [`bootstrap.sh`](bootstrap.sh) | Scaffold a new repo from the templates. |
| [`sync.sh`](sync.sh) | Push the ritual layer (skills, subagent, model policy, guard hooks) into an existing repo as a reviewable diff. |

## Three tiers of repo

- **Below the line** — throwaway scripts, one-evening experiments. `AGENTS.md` only. No tracker, no PRs. Outside the rituals.
- **On the playbook** — anything you'll come back to. `VISION.md`, `AGENTS.md`, a **declared tracker**, the rituals, branch → PR, pre-commit hook, `DECISIONS.md`. The loop from the first commit. **Linear** when the work has stakeholders beyond you (ventures); **GitHub Issues** when you're the only one (tools, MCP servers, open source). Same playbook either way.
- **Hardened** — when the codebase can break: + CI, branch protection, secret scanning; with real users: + staging, platform CI.

Coordinator, automations, and bot reviewer are not tiers. Each turns on when its trigger fires (`PLAYBOOK.md` → *Earned machinery*).

## Quick start

```bash
# A venture (Linear is the default tracker)
./bootstrap.sh ~/Developer/my-new-app "My New App" "one-line product thesis"

# A solo tool / MCP server / open-source repo (GitHub Issues as the tracker)
./bootstrap.sh ~/Developer/my-tool "My Tool" "one-liner" --tracker github

# iOS? add --ios for the Xcode MCP config + iOS agent conventions
./bootstrap.sh ~/Developer/my-ios-app "My iOS App" "one-liner" --ios
```

The bootstrap copies the templates, fills `{{PLACEHOLDERS}}` (including the tracker), inits git with the pre-commit hook enabled, and prints the human steps for the chosen tracker. Then: create a tracker project, `/plan <project>`, accept and promote, `/start-unit <issue-id>`.

## The rituals

Agent Skills in `.agents/skills/<name>/SKILL.md` (Claude Code follows the `.claude/skills` symlink). Each runs only when you type `/<name>`. The folders are the menu.

| Skill | When | What it does |
|---|---|---|
| `/plan <project \| issue>` | A tracker project goes active, or a Deep-lane issue is next | **Project mode:** decomposes the project into session-sized issues in the tracker — first one or two fully specified, the rest thin — and stops. Never moves status. **Issue mode:** expands one Deep-lane issue into a gated plan at `plans/features/<issue-id>-<slug>.md` and stops. Standard-lane issues skip this; the issue is the spec. |
| `/start-unit <issue-id>` | Begin one unit | Fetches the issue from the declared tracker (stops if it can't), checks Todo + entry dependency + WIP limit, restates the gate as definition of done, branches `<issue-id>-<slug>`, builds only that. |
| `/close-unit <issue-id>` | Gate is met | Verifies every gate item has evidence the reviewer can open, updates `docs/status.md` + landing pad, deletes the plan file if any, commits → pushes → opens the PR. Stops there; the human merges. |
| `/context-sync` | After any session | Reconciles `docs/status.md`, landing pad, conventions, decisions with what actually changed. No feature code. |

**Subagent:** `.claude/agents/code-review.md` — read-only reviewer against the repo's actual conventions and the issue's gate; returns `BLOCK` / `APPROVE-WITH-FIXES` / `APPROVE`. The same review unattended on every PR is the `pr-review` automation (earned).

**Coordinator:** `templates/docs/coordinator.md` — the one-page brief for a Cursor Project, off by default. Pulls from Todo, plans Deep-lane issues, dispatches, watches PRs to green, verifies evidence, reports. Never writes code, never merges.

## Non-negotiables (every lane, every repo on the playbook)

- A tracker issue as the record. Issues live in the declared tracker and nowhere else.
- One issue = one branch `<issue-id>-<slug>` = one PR. `main` is sacred.
- Gate evidence on the PR, tiered `[CI]` / `[ARTIFACT]` / `[MANUAL]`, judgeable in ~30 seconds on a small screen (so it's fast on a laptop too). Only tag what a tool the agent actually has can produce.
- Agents never move issue status by hand (undoing their own mistake and the Fast lane excepted). Humans click.
- One issue being built per repo at a time. Open PRs awaiting review don't count.
- Execution agents never read the thinking layer.

## Reference implementation and sandbox

**NOVA** is the reference implementation once it has code. **SmartSport** (`~/Developer/smartSportApp`) is the **sandbox**: workflow experiments run there first, and they test workflow, never features. SmartSport's own feature work is a portfolio call, not a doctrine one.

## How this repo changes

One **steward** — a Claude Code agent (strong tier) launched in this repo — owns doctrine and templates. The one exception: a Cursor thread that has verified how a Cursor feature actually behaves may open a narrow PR fixing that fact, with its own `CHANGELOG.md` entry. Direction comes from Nathan and the Chief of Staff; the steward turns decisions into text, keeps `FRICTION.md` and `CHANGELOG.md`, and pushes back when a decision has an implementation problem. Everyone else who hits friction — a Cursor thread, a venture agent, a human — appends to `FRICTION.md` with the exact correction if they know it. Friction is reviewed every two weeks; the steward proposes, Nathan decides, the change ships as a PR that Nathan merges. Doctrine first (`PLAYBOOK.md`), then templates, then `sync.sh` into a venture as a separate reviewed step. Doctrine PRs never sync into a venture.

Doctrine is written in **roles** (tracker, coordinator, executor, reviewer, supervisor). Product names live in `docs/surfaces.md` so a vendor shipping a feature changes one dated file, not the rules.
