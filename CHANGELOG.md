# Changelog — why the doctrine changed

> One entry per merged doctrine PR: date, what was decided, why. This is the steward's memory and the only place the playbook's history lives. Newest at the top. `PLAYBOOK.md` says what the rule is; this file says why it became the rule.

## 2026-09-22 — One mode, per-repo tracker, organizing work, WIP limit, earned machinery (PR #3)

**Decided by:** Nathan + Chief of Staff (Renaissance HQ), Sept 19–22; reviewed and executed by the Cursor playbook thread as its last doctrine change before the steward took over.

- **Removed "phase mode vs continuous mode."** The split was a transition artifact from when the phase folder predated Linear. It produced two queues, two branch conventions, two rituals, and hid pre-v1 work from non-technical co-founders (who can see Linear, not `plans/`). A phase is now a tracker project; all work is issues from the first commit; the branch is always `<issue-id>-<slug>`.
- **`/plan-phase` files issues, not files** — and fully specifies only the first one or two. A greenfield decomposition is wrong by the fourth unit; over-specified issues are worse than over-specified plan files because agents treat issue text as the spec. Thin issues get criteria as they approach Todo.
- **Tracker declared per repo; GitHub Issues sanctioned for the solo tier.** The rule "Issues are Linear issues, GitHub Issues are unused" was written to stop one SmartSport agent from wandering and was too strong as portfolio doctrine. Linear is for work with stakeholders beyond Nathan (ventures); GitHub Issues for solo tools, MCP servers, open source — same playbook, same rituals. Also the practical reason: Linear free tier allows two teams and SmartSport + NOVA use both. A **below-the-line** tier (throwaway scripts: `AGENTS.md` only, no loop) was named explicitly.
- **Object definitions and graduation path** (Weekly Goal / Project / Milestone / Issue / labels; Notion → Triage → Backlog → project → Todo). An issue is a session of work, not a change: in-scope tweaks are commits, out-of-scope finds are new issues, polish is captured into one Backlog issue per project and worked as a single session.
- **Status ownership stated precisely** so nobody guts `docs/status.md`: tracker owns delivery state, Notion links, repo keeps code-side history. Whether `status.md` survives long-term is a friction-log item.
- **WIP limit:** one issue being built per repo; open PRs awaiting review don't count (the tracker holds them In Progress by automation); parallel cloud-delegated units only when a coordinator exists.
- **Earned machinery replaces the stage ladder** for coordinator / automations / bot reviewer: each turns on by a trigger (Todo outgrows your head; a ritual repeated ~5×; reviews being skimmed), all off by default. The repo-hardening ladder (CI, branch protection, secret scanning, staging) stays stage-based. "Maybe direct commits to `main`" was removed from every tier that has a tracker.
- **Bug intake:** found-while-coding → Fast lane, the coding agent files and fixes; found-while-using → one-line Triage capture, tracker agent shapes product side only, code-aware agent investigates read-only first. No meaningful change merges without an issue.
- **Model policy routes by tier, not tool loyalty:** `fast`/`mid` → Cursor; `strong` → Claude Code on Opus 5.5 starting at medium effort; Codex → overflow and second-opinion review only. Planning happens where the budget resets often. Account-level billing facts stay out of templates — for the record: the reason Codex is "not structural" is that the ChatGPT student promo it runs on ends around January 2027.
- **SmartSport paused (Sept 19) and made the sandbox; NOVA becomes the reference implementation** once it has code. Experiments test workflow, never features.
- **Playbook steward** defined: one Claude Code agent is the only writer of doctrine and templates; direction from Nathan + Chief of Staff; memory in `PLAYBOOK.md` / `CHANGELOG.md` / `FRICTION.md`. Cursor threads log corrections in `FRICTION.md` rather than opening PRs — one writer, no exceptions, to avoid recreating the two-writer problem.
- **New files:** `FRICTION.md`, `CHANGELOG.md`.

## 2026-09-21 — Proportional rigor: fast / standard / deep lanes (PR #2)

Every change went through Triage → plan file → `/start-unit` → `/close-unit`, which was all ceremony for bugs already diagnosed in a coding session. Lanes scale approval and planning with risk; the issue, PR, and evidence never shrink. Fast lane: human "go" in chat → agent files the issue straight into In Progress → fix + evidence → PR. Standard: Todo issue is the spec. Deep: `/plan-feature` → human review. Also: who shapes an issue depends on code access (tracker agent = product side, code agent = technical side).

## 2026-09-20 — Claude Code as a first-class surface (PR #1)

Claude Code desktop gained an embedded iOS Simulator panel, a browser pane, and its own Remote Control, so the one-line "debugging surface" entry undersold it. Added a project `.mcp.json` to the iOS overlay (parity with Cursor), a tier → Claude model mapping in the model policy, and an `AGENTS.md` rule that scoped `.cursor/rules/*.mdc` bind non-Cursor agents too. Known limitation recorded later: the simulator pane requires Xcode 26.x via `xcode-select` and does not work with Xcode 27's Device Hub.
