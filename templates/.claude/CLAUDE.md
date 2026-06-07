# {{PROJECT_NAME}} — Claude Code entry point

> This file exists for Claude Code's automatic context loading.
> **The single source of truth for all AI agents is [`AGENTS.md`](../AGENTS.md) at the repo root.** Read it first. Keep this file a thin pointer so Cursor and Claude Code never drift.

## Where things live (volatility-separated, all in-repo)

| Need | File |
|---|---|
| Product thesis | [`VISION.md`](../VISION.md) |
| Agent constitution + landing pad | [`AGENTS.md`](../AGENTS.md) |
| Architecture decision log | [`DECISIONS.md`](../DECISIONS.md) |
| Changelog / status | [`docs/status.md`](../docs/status.md) |
| Git / CI / review workflow | [`docs/git-workflow.md`](../docs/git-workflow.md) |
| Active plans + gates | [`plans/`](../plans/) |
| Cursor scoped rules | [`.cursor/rules/`](../.cursor/rules/) |

Plans live in-repo under `plans/` so they travel with every clone and cloud agent. Cursor's plan mode and Claude Code's todos are ephemeral scratch.

## Coordinating with other agents

1. Update [`AGENTS.md`](../AGENTS.md) first — every agent reads it.
2. Record expensive-to-reverse decisions in [`DECISIONS.md`](../DECISIONS.md).
3. Update the relevant `.cursor/rules/*.mdc` for glob-scoped conventions.
4. Never commit to `main`; work on a branch and open a PR (see `docs/git-workflow.md`).

## Subagents, commands, hooks

- `.claude/agents/` — active subagents (e.g. `code-review`). Keep aligned with `AGENTS.md`.
- `.claude/commands/` — rituals (`/context-sync`, `/plan-phase`, `/start-unit`, `/close-unit`).
- Guard: git pre-commit hook `.githooks/pre-commit` (enable once with `git config core.hooksPath .githooks`) + early `.cursor/hooks.json` secret block.
