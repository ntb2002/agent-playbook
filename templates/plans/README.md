# Plans

> The durable home for active work plans. **In-repo on purpose** so plans travel with every clone, device, and cloud agent. Cursor's `.plan.md` and Claude Code's todo list are ephemeral scratch — when a plan matters, it gets written here and committed.

## How plans work

1. **Roadmap lives in `AGENTS.md`** as a terse phase table; the active phase points here.
2. **When a phase becomes active**, a strong model expands it into `plans/<phase>/`: a `README.md` overview + one file per session-sized unit. The planning agent **writes the plan and stops**; a human reviews/approves before any execution.
3. **Match ceremony to maturity:** fully expand only the *next* unit; keep later units as roadmap bullets.
4. **Each unit has an entry dependency + a verification gate.** Execute one at a time: build → verify gate → update `docs/status.md` + landing pad → PR → next.
5. **Expensive-to-reverse decisions** get logged in `DECISIONS.md`.

## Verification gates (phone-checkable)

Tag each gate item by evidence tier:

- **[CI]** — a green check proves it. Best tier. Only tag `[CI]` if the check actually exists.
- **[ARTIFACT]** — screenshot / recording / log / curl output attached to the PR. Includes agent-captured evidence: build/test output or simulator screenshots via local tools (e.g. Xcode MCP).
- **[MANUAL]** — hands-on verification an agent genuinely can't do (physical device, real payments/push, subjective feel). Spell out exact steps + expected result.

A unit is done only when every gate item is checked with evidence on the PR.

## Active plans

- <link to active phase folder>
