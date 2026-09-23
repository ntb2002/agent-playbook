# agent-playbook

Portfolio-wide standard for building software with AI coding agents (Cursor, Claude Code, cloud agents, and the coordinators that run them), optimized for a founder orchestrating multiple agents across multiple ventures and reviewing on the go.

## Contents


| Path                           | What                                                                                                  |
| ------------------------------ | ----------------------------------------------------------------------------------------------------- |
| `[PLAYBOOK.md](PLAYBOOK.md)`   | The doctrine — the seven principles, automation primitives, orchestration model. **Read this first.** |
| `[bootstrap.sh](bootstrap.sh)` | Scaffold a new project from the templates.                                                            |
| `[sync.sh](sync.sh)`           | Push ritual-layer updates (skills, subagent, model policy, guard hooks) into an existing venture repo. |
| `[templates/](templates/)`     | Copy-ready files: context docs, plans skeleton, CI, hooks, rules, skills, subagent, PR template, coordinator brief, automation prompts. |
| `templates/SETUP.md`           | Per-project setup checklist: the venture cell, tracker at bootstrap, branch protection, phone orchestration, cloud agents, earned machinery (coordinator / automations / bot reviewer, each by trigger), iOS. |
| `[overlays/](overlays/)`       | Platform overlays layered by `bootstrap.sh` flags (currently `--ios`: Xcode MCP + iOS agent conventions). |
| `[CHANGELOG.md](CHANGELOG.md)` | Why each doctrine change was made (one entry per merged doctrine PR). |
| `[FRICTION.md](FRICTION.md)`   | Append-only log of what was clunky or wrong in practice; the steward proposes changes from it. |




## Quick start

```bash
# Scaffold a venture (Linear is the default tracker)
./bootstrap.sh ~/Developer/my-new-app "My New App" "one-line product thesis"

# Solo tool / MCP server / open source? Use GitHub Issues as the tracker
./bootstrap.sh ~/Developer/my-tool "My Tool" "one-liner" --tracker github

# iOS project? Add --ios to layer in the Xcode MCP config + iOS agent conventions
./bootstrap.sh ~/Developer/my-ios-app "My iOS App" "one-liner" --ios

# Then in the new repo:
cd ~/Developer/my-new-app
git config core.hooksPath .githooks   # enable the pre-commit hook
```

The bootstrap copies the templates, replaces `{{PLACEHOLDERS}}`, and prints the human steps for the chosen tracker. The tracker exists from the first commit; the machinery (coordinator, automations, bot reviewer) stays off until a trigger fires.

## Workflow skills & subagents

The rituals are **Agent Skills** — `SKILL.md` files in `.agents/skills/<name>/` (the `templates/.agents/skills/` copies). Each skill is a saved prompt with `disable-model-invocation: true`, so it runs only when you explicitly type `/<name>`. **To see them all, list** `.agents/skills/` — the folders *are* the menu. Type `/<name>` in Cursor or Claude Code; both tools discover skills from `.agents/skills/` natively (Claude Code also follows the `.claude/skills` symlink).


| Skill                     | When                | What it does                                                                                                                                                             |
| ------------------------- | ------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `/plan <project \| issue>` | A tracker project goes active, or a Deep-lane issue is next | **Project mode:** strong model decomposes the project into session-sized issues filed into the tracker — the first one or two fully specified, the rest thin — and **stops**. Never moves status; you accept and promote. **Issue mode:** expands one Deep-lane issue into a single gated unit at `plans/features/<issue-id>-<slug>.md` and **stops**. Refuses to invent missing acceptance criteria. Standard-lane issues skip this: the issue is the spec. |
| `/start-unit <issue-id>`  | Begin one unit      | Fetches the issue from the declared tracker, loads conventions, restates the gate as "definition of done," branches `<issue-id>-<slug>`, implements only that unit. No commit yet. |
| `/close-unit <issue-id>`  | Unit's gate is met  | Verifies each gate item with evidence, updates `docs/status.md` + AGENTS landing pad, deletes the plan file if there was one, then commits → pushes → opens the PR. Stops at the open PR (you merge). |
| `/context-sync`           | After any session   | Reconciles the docs with what actually changed (status, landing pad, conventions, decisions). No feature code.                                                           |


**Subagent:** `.claude/agents/code-review.md` — a read-only reviewer (Sonnet) that checks a diff against the project's actual conventions and the unit's gate, then returns BLOCK / APPROVE-WITH-FIXES / APPROVE. Never edits or commits. Invoke before opening a PR (Claude Code subagent, or Cursor's `code-review` Task). The same review, run unattended on every PR, is the `pr-review` automation in `templates/.cursor/automations/`.

**Coordinator:** `templates/docs/coordinator.md` — the one-page brief you point a Cursor Project at, **off by default** until its trigger fires. It pulls the next Todo issue, runs `/plan <issue-id>` for Deep-lane issues, dispatches an execution agent, watches the PR to green, verifies the gate evidence, and reports. Never writes code, never merges.

The loop, at any stage: tracker issue in Todo → `/start-unit` (Deep lane: `/plan <issue-id>` → you approve → `/start-unit`) → `code-review` → `/close-unit` → (you merge on phone; the tracker closes the issue) → `/context-sync`. Before a coordinator exists, you are the middle column — pick the issue, review the PR. Once one exists, it pulls and dispatches and you review.

## Reference implementation and sandbox

**NOVA** is the reference implementation once it has code. **SmartSport** (`~/Developer/smartSportApp`) is paused and is the sandbox: workflow experiments run there first, and they test workflow, never features. When a practice proves out, generalize it into `PLAYBOOK.md` first, then `templates/`.

## Tiers (don't over-build early)

- **Below the line** — throwaway scripts, one-evening experiments: `AGENTS.md` only. No tracker, no PRs. Outside the rituals.
- **On the playbook** — anything you'll come back to: `VISION.md`, `AGENTS.md`, a declared tracker (Linear for ventures, GitHub Issues for solo tools), rituals, branch → PR, pre-commit hook, `DECISIONS.md`. The loop from the first commit.
- **Can break:** + CI, branch protection, secret scanning, `plans/` Deep-lane specs.
- **Real users:** + staging env, secret scanning in CI, platform CI.
- **Machinery** (coordinator, automations, bot reviewer) is not a stage — each turns on when its trigger fires. See `PLAYBOOK.md` → *Earned machinery*.

See `PLAYBOOK.md` for the full rationale, `CHANGELOG.md` for why it changed, `FRICTION.md` for what's still wrong.