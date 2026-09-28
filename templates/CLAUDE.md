@AGENTS.md

## Claude Code

- **Subagents:** `.claude/agents/` (`code-review`; `evaluator` for browser products). Call them without asking. Keep aligned with `AGENTS.md`.
- **Skills:** `.agents/skills/` (project rituals: `/plan`, `/start-unit`, `/close-unit`, `/context-sync`). A `.claude/skills` symlink points here.
- **Hooks:** enable the git pre-commit hook once per clone: `git config core.hooksPath .githooks`. Cloud VMs: `.cursor/environment.json` runs this on install.
