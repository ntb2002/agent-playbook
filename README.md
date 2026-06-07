# agent-playbook

Portfolio-wide standard for building software with AI coding agents (Cursor, Claude Code, cloud agents), optimized for a solo builder orchestrating multiple agents and reviewing from a phone.

## Contents

| Path | What |
|---|---|
| [`PLAYBOOK.md`](PLAYBOOK.md) | The doctrine — the seven principles, automation primitives, orchestration model. **Read this first.** |
| [`bootstrap.sh`](bootstrap.sh) | Scaffold a new project from the templates. |
| [`templates/`](templates/) | Copy-ready files: context docs, plans skeleton, CI, hooks, rules, commands, subagent, PR template. |
| `templates/SETUP.md` | Per-project setup checklist (branch protection, Slack/GitHub mobile, cloud-agent bootstrap). |

## Quick start

```bash
# Scaffold a new project
./bootstrap.sh ~/Developer/my-new-app "My New App" "one-line product thesis"

# Then in the new repo:
cd ~/Developer/my-new-app
git config core.hooksPath .githooks   # enable the pre-commit hook
```

The bootstrap copies the templates, replaces `{{PLACEHOLDERS}}`, and prints which maturity layer to enable next.

## Workflow commands & subagents

The rituals are **slash commands** — markdown files in `.claude/commands/` (the `templates/.claude/commands/` copies). Each file is a saved prompt; the YAML `description`/`argument-hint` at the top tells you what it does and what to pass. **To see them all, just list that folder** — the files *are* the menu. Run one in Claude Code by typing `/<name>`; in Cursor, open the command file and run it as a prompt (or keep a Cursor `.cursor/commands/` mirror).

| Command | When | What it does |
|---|---|---|
| `/plan-phase <phase>` | A phase goes active | Strong model expands the phase into gated, session-sized units under `plans/<phase>/` and **stops** — writes the plan, builds nothing. You review/approve. |
| `/start-unit <unit-path>` | Begin one unit | Loads context + conventions, restates the unit's gate as "definition of done," implements only that unit. No commit yet. |
| `/close-unit <unit-path>` | Unit's gate is met | Verifies each gate item with evidence, updates `docs/status.md` + AGENTS landing pad, then branches → commits → pushes → opens the PR. Stops at the open PR (you merge). |
| `/context-sync` | After any session | Reconciles the docs with what actually changed (status, landing pad, conventions, decisions). No feature code. |

**Subagent:** `.claude/agents/code-review.md` — a read-only reviewer (Sonnet) that checks a diff against the project's actual conventions and the unit's gate, then returns BLOCK / APPROVE-WITH-FIXES / APPROVE. Never edits or commits. Invoke before opening a PR (Claude Code subagent, or Cursor's `code-review` Task).

Typical loop: `/plan-phase` → (you approve) → `/start-unit` → `code-review` → `/close-unit` → (you merge on phone) → `/context-sync`.

## The reference implementation

`~/Developer/smartSportApp` is the live reference. When a practice proves out there, generalize it back into `templates/` + `PLAYBOOK.md` (doctrine first, then templates).

## Maturity ladder (don't over-build early)

- **Idea:** `VISION.md` + rough phases.
- **Prototype:** + `AGENTS.md`.
- **Can break:** + branch/PR, pre-commit hook, CI, branch protection, `plans/` gates, `DECISIONS.md`.
- **Real users:** + bot reviewer, secret scanning, staging env.

See `PLAYBOOK.md` for the full rationale.
