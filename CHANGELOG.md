# Changelog — why the doctrine changed

> One entry per merged doctrine PR: date, what was decided, why. This is the steward's memory and the only place the playbook's history lives. Newest at the top. `PLAYBOOK.md` says what the rule is; this file says why it became the rule.

## 2026-09-30 — Branch from `origin/main`, merge it before the PR

NOVA's first unit (NV-1) was cut from a local `main` still at the scaffold commit, after nova#1 had merged on GitHub. The branch missed #1's design notes and landing-pad lines, and its `AGENTS.md` looked like it had reverted. SmartSport had hit the same thing. Cause: `/start-unit` ran `git checkout -b` from whatever was checked out. Merges happen on GitHub's servers (web, mobile, Linear Reviews, `gh pr merge`), so local `main` is almost always behind in this workflow, laptop included.

Fix, in the ritual rather than in anyone's memory:
- `/start-unit` refuses a dirty tree, fetches, and cuts the branch from `origin/main` (`--no-track`). A resumed branch merges `origin/main`.
- `/close-unit` fetches and merges `origin/main` before pushing, re-runs `[CI]` items if that brought changes, resolves only in-scope conflicts, and never force-pushes. Its `allowed-tools` gain `git fetch`/`git merge`, plus the `git rm` its own step 4 already needed.
- `docs/git-workflow.md` explains why.

Not adopted: auto-pulling local `main`. Branching from `origin/main` makes local `main`'s staleness irrelevant, and it can't fail on local changes. A NOVA-only patch to the skill was also declined: `sync.sh` replaces skills wholesale, so it would have been overwritten and SmartSport would never have received it.

## 2026-09-29 — Bootstrap friction from NOVA: root commit, retired stubs, VISION header

NOVA was bootstrapped on Sept 28–29 and surfaced three small gaps; Nathan decided each.
- **Root-commit exception** (principle 6, `bootstrap.sh` next steps). "Never commit to `main`" had no answer for a brand-new repo, where there's nothing to branch from. The scaffold's root commit goes on `main`, made by the human or on the human's explicit say-so. Nothing else is exempt.
- **`/plan-phase` and `/plan-feature` stubs removed from templates.** They were kept for one sync cycle so muscle memory wouldn't fail silently (PR #4). SmartSport has had its cycle, and a new repo has no muscle memory to protect, so shipping them into NOVA was pure noise. `sync.sh` replaces `.agents/skills` wholesale, so they drop out of a venture on its next sync.
- **`templates/VISION.md` header** said day-to-day "how" lives in `plans/`, which contradicts the one-mode doctrine (PR #3). It now says what's next lives in the declared tracker, and `plans/` holds Deep-lane specs only.

## 2026-09-28 — `.claude/settings.json`: deny list for protected checks

Follow-up to PR #7, approved by Nathan: "go on settings.json, with a deny list that includes the verifier and CI paths." The template now ships `.claude/settings.json`.
- **deny:** CI config, git and Cursor hooks, `evals/`, force-push, pushing to `main`, `--no-verify`, `git config core.hooksPath`, `gh pr merge`.
- **allow:** routine git/`gh`/project-check/Playwright commands.
- **Verifier paths:** protected material goes under `evals/` by convention. A verifier elsewhere (e.g. the kernel spike's `spike/bench/`) gets its own deny line, added by the issue that builds it. Because `.claude/` is a protected path, that edit is human-approved.

**Changed from what was proposed in #7.** The proposal said "`acceptEdits` + allow rules." Claude Code's docs now say the built-in starting mode is **auto**, and a project-level `defaultMode` of anything else overrides it. `acceptEdits` would therefore have *reduced* agent latitude, so the template sets no `defaultMode`. Deny rules apply in every mode.

**Stated limit.** Edit-deny covers file tools, `sed`/`tee`, and redirects, but not a script that writes the file itself. The deny list is a tripwire; the reviewer's `BLOCK` stays the gate. `sync.sh` seeds the file if missing and never overwrites it, because each repo's deny list grows over time.

## 2026-09-28 — Autonomy inside the box: in-task autonomy, loop bounds, loop issues, evaluator

**Decided by:** Nathan + Chief of Staff, Sept 28. **Doctrine-freeze exception:** this is foundational, and NOVA's first issue is days away. Changing it after NOVA has run a dozen units costs more than changing it now.

**Why.** Nathan asked whether "earned machinery" had become too conservative. The two references were Karpathy's `autoresearch` (March 2026) and DHH's Rails World keynote (Sept 23). In `autoresearch`, an agent edits a training script, runs a 5-minute experiment, checks one metric, and keeps or reverts the change. It ran about 700 trials in two days with no human in the loop. That works because of a cheap verifier the agent can't edit, plus a written loop spec (`program.md`). In the keynote, 37signals is "pencils down" on hand-written code: engineers hand an agent an outcome and review what comes back, and hand-writing code is a signal that the agent workflow needs repair. The model the two share: **total autonomy inside a box, with a human who owns the edges of the box.** Neither builds sprawling toolkits, and both give agents far more in-task latitude than the playbook stated. The old "earned machinery" rule mixed two separate things, overhead and autonomy. This change separates them.

**What changed.**
- New *Autonomy inside the box* section. Inside an approved issue, an agent edits, runs, iterates to a green gate, calls subagents, commits, and opens the PR without asking. The box is the gate, the protected checks, one branch, and the loop bounds. The edges stay human: what's next, merge, anything irreversible or external.
- **Protected checks:** gate tests existing at branch start, eval sets, fixtures, scorers, rubrics, and CI config. The spec protected "the test files named as the gate," but executors usually *write* the gate's tests. So tests the agent adds are reviewed, not protected. Weakening, skipping, or deleting an existing test is forbidden. The reviewer `BLOCK`s a PR that touches a protected check unless changing that check is the issue's purpose.
- **Loop bounds** table and a four-part escalation note.
- **Principle 5 reconciled.** "Escalate on first failure" contradicted "up to 3 correction rounds." A correction round is now normal work inside a run. A *run* fails when it hits a loop bound or its PR is `BLOCK`ed, and the next run goes to the strong tier.
- **Loop issues** with a `## Loop spec` modeled on `program.md`, plus the NOVA geometry-kernel spike as the worked example. Added requirements: the verifier ships first as its own issue (a loop can't build its own judge), and the loop yields evidence, while the decision it informs goes to `DECISIONS.md`.
- **Evaluator** role and `templates/.claude/agents/evaluator.md`. A fresh-context agent drives the running app with Playwright against the acceptance criteria, strict by instruction. Pattern from `affaan-m/ecc`'s generator/evaluator pair, taken as reference only; the repo is not a dependency. `sync.sh` now copies every subagent.
- **Earned machinery unchanged in substance.** It now says outright that the trigger guards against overhead, not risk, and that in-task autonomy is never earned.

## 2026-09-22 — Stacked doctrine restored to `main`; steward handoff

PRs #3, #4 and #5 were stacked. #3 merged to `main`; #4 then merged into #3's branch and #5 into #4's, so `main` never received `/plan` or the roles/surfaces rewrite, and the CHANGELOG entries below for #4 and #5 were not on `main` either. Nothing retargeted them because `delete_branch_on_merge` is off in this repo — with it on, GitHub retargets a stacked PR to `main` when its base branch is deleted on merge. SmartSport's sync (smartSportApp#30) was taken from the top of the stack, so for a while the sandbox carried doctrine the playbook's own `main` did not. This PR carries #4 and #5's content to `main` unchanged. No doctrine was rewritten in the process.

Also: the stewardship moved from the Cursor playbook thread to a Claude Code agent. The one addition made on handoff: a Cursor-mechanics PR adds its own `CHANGELOG.md` entry, and the steward never reverts one without asking Nathan.

## 2026-09-22 — Roles, not products (PR #5)

The orchestration section named Cursor Projects, Automations, Remote Control, the Cursor iOS app, Grok Bot, and Claude Code desktop inside doctrine, so every vendor change produced a doctrine error. Case in point: the doctrine claimed a Cursor Remote Control session inherits the chat's project-scoped `.cursor/mcp.json`; Cursor's docs say the worker's MCP comes from the Cloud Agents configuration routed by transport (stdio on the Mac, HTTP on Cursor's backend), and that a named `worker=` machine can be targeted from Linear/Slack/GitHub. Rewrote the section as roles (tracker / human / coordinator / executor / reviewer / supervisor / thinking agent) with does / never does / owes, plus two evidence lanes chosen by where the executor runs. Product facts moved to a new, dated `docs/surfaces.md`, including the Remote Control correction, the Claude Code desktop simulator pane's Xcode 26.x requirement, and the Codex line (overflow + review only; repo is source of truth; confirm hooks fire before trusting a commit). `README.md` rewritten as the onboarding doc for the steward and anyone else landing here — no history of the old system except in this file.

**Amended the same day, on Nathan's review:** (1) "human, on a phone" → the human; phone-reviewability is the design bar, not a rule about where review happens. (2) Supervisor's *never does* dropped "write code" — the agent in that role may code elsewhere; in the role it verifies. (3) Steward scope: Cursor threads may open narrow PRs for verified Cursor-mechanics corrections (Nathan overrode the CoS's stricter "FRICTION.md only"). (4) SmartSport is the sandbox regardless of whether its feature work is paused; the pause itself is a portfolio call, not doctrine.

## 2026-09-22 — One planning ritual: `/plan` (PR #4)

`/plan-phase` and `/plan-feature` were the same act at two sizes; the split existed because the phase folder predated the tracker. Merged into `/plan <arg>`: an issue id → issue mode (Deep-lane spec into `plans/features/`), anything else → project mode (decompose into thin issues in the tracker). Done now rather than later because the blast radius was near zero — SmartSport paused, NOVA not yet bootstrapped — and it never gets cheaper. The old names ship as one-line deprecation stubs for one sync cycle so muscle memory doesn't fail silently, then get deleted from templates.

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
