# Friction log

> Append-only. What was clunky, wrong, or missing when the playbook met reality. Anyone — a Cursor thread, a venture agent, a human — appends here; **the steward edits doctrine** (Cursor threads may PR verified Cursor-mechanics corrections directly). Reviewed with the Chief of Staff every two weeks; the steward proposes changes from it, Nathan decides. When an entry is resolved, add a `→ resolved:` line pointing at the PR; don't delete it.
>
> Entry format: `### YYYY-MM-DD · <repo> · <one-line summary>` then: what happened, which doctrine section it touches, the exact correction if you know it.

### 2026-09-17 · smartSportApp · Full ritual chain was too heavy for small fixes

`/plan-phase` → `/plan-feature` → `/start-unit` → `/close-unit` for a bug already diagnosed in a coding session was all ceremony and no added proof. Touches: *Tracker rules*. → resolved: proportional-rigor lanes (PR #2), and the one-mode conversion (PR #3).

### 2026-09-21 · agent-playbook · Remote Control MCP claim was wrong

`PLAYBOOK.md` (*Orchestration model → Remote Control*) and `templates/SETUP.md` (*iOS → project-scoped `.cursor/mcp.json`*) said a Cursor Remote Control session inherits the chat's project-scoped `.cursor/mcp.json`. Cursor's docs say Remote Control uses the Cloud Agents MCP set chosen at launch; stdio servers (e.g. `xcrun mcpbridge`) can be added there and run on the Mac, but a new run is required. Exact correction: replace "inherits the chat you started `/remote-control` in — workspace root, project-scoped `.cursor/mcp.json`" with the Cloud-Agents-MCP-set statement, and stop telling people to start Remote Control from the venture chat *for MCP reasons* (still start it there for the workspace root). Touches: *Orchestration model*, SETUP *iOS*. → resolved: PR #5 (`docs/surfaces.md`).

### 2026-09-22 · agent-playbook · `docs/status.md` may be redundant once the tracker owns delivery state

With Linear/GitHub Issues owning what's next / in progress / done, `docs/status.md` overlaps with `git log` + the tracker. Kept for now as code-side history (what shipped, open technical threads). Revisit after NOVA has a month of history: if nobody reads it, fold it into the landing pad and delete. Touches: *principle 1*, *Organizing work → status ownership*.

### 2026-09-22 · agent-playbook · Two planning skills for one act

`/plan-phase` and `/plan-feature` are the same act at different sizes; the split exists because the phase folder existed first. Touches: *Automation primitives → Skills*. → resolved: PR #4 (`/plan`).

### 2026-09-22 · agent-playbook · Orchestration section is written in product names

Cursor Projects, Automations, Remote Control, Grok Bot, Claude Code desktop are woven into doctrine, so every product change creates a doctrine error (see the Remote Control entry). Should be roles (tracker / coordinator / executor / reviewer / supervisor) plus a dated, perishable surface map. Touches: *Orchestration model*. → resolved: PR #5.

### 2026-09-22 · agent-playbook · Stacked PRs merged into each other, not `main`

#4 and #5 were based on the branch below them. After #3 merged, their bases were not retargeted, so merging them landed doctrine on dead branches while GitHub showed them as MERGED. Cause: `delete_branch_on_merge` is off here, though `templates/SETUP.md` tells ventures to turn it on. Correction: turn on "Automatically delete head branches" for this repo (Nathan — settings), and before merging any stacked PR confirm its base is `main`. Touches: *principle 6*, steward workflow. → resolved: content restored by the stack-restore PR; setting change pending.

### 2026-09-28 · agent-playbook · Watch: automatic session learning

Candidate for later, not adopted. ECC's continuous-learning pattern: sessions are observed, and the steward turns findings into proposals that Nathan approves. It would feed this file automatically instead of relying on agents to remember to append. Revisit once NOVA has produced a few weeks of sessions and we can see whether manual friction capture is actually missing things. Touches: *The playbook steward*.

### 2026-09-28 · agent-playbook · Watch: autonomy should go down as well as up

*Autonomy inside the box* sets one latitude for every executor. If correction rounds or escalations pile up for a tier, a repo, or a kind of issue, latitude should drop there: tighter loop bounds, Deep lane by default, or a human checkpoint mid-run. No signal yet. Watch NOVA's escalation notes. Touches: *Autonomy inside the box*, *principle 5*.

### 2026-09-28 · agent-playbook · Protected-check deny list is Claude Code only

`.claude/settings.json` gives Claude Code sessions a deny list for protected checks. Cursor's equivalent (the IDE's auto-run allow/deny, `.cursor/cli.json` for the CLI, and what cloud agents honor) was not verified, so Cursor executors rely on the rule in `AGENTS.md` and the reviewer's `BLOCK` alone. Correction wanted from a Cursor thread that verifies it: which repo file, if any, carries a path deny list that Cursor agents and cloud VMs enforce. Touches: *Autonomy inside the box → The box*, `docs/surfaces.md`.

### 2026-09-28 · nova · No rule for a new repo's first commit

`bootstrap.sh` leaves the scaffold uncommitted, and principle 6 says never commit to `main`, but a new repo has nothing to branch from. Touches: *principle 6*, `bootstrap.sh`. → resolved: root-commit exception, bootstrap-friction PR.

### 2026-09-28 · nova · Retired `/plan-phase` and `/plan-feature` stubs shipped into a new repo

The one-sync-cycle deprecation stubs from PR #4 were still in `templates/`, so bootstrap copied them into NOVA, which had no old names to redirect. Touches: `templates/.agents/skills/`. → resolved: stubs removed from templates, bootstrap-friction PR (deleted from NOVA before its root commit).

### 2026-09-28 · nova · `templates/VISION.md` header contradicts one-mode doctrine

Line 3 said day-to-day "how" lives in `plans/`. Since PR #3, what's next lives in the tracker and `plans/` holds Deep-lane specs only. NOVA's copy was fixed by hand before its root commit. Touches: `templates/VISION.md`. → resolved: bootstrap-friction PR.

### 2026-09-30 · nova · Unit branch cut from a stale local `main`

NV-1's branch started at the scaffold commit because local `main` hadn't been pulled after nova#1 merged on GitHub. `AGENTS.md` appeared to revert, and the branch would have conflicted with or undone #1. Same failure seen earlier in SmartSport. Touches: `/start-unit`, `/close-unit`, `docs/git-workflow.md`. → resolved: branch-from-`origin/main` PR. NV-1 itself was repaired by hand (`git fetch origin && git merge origin/main`).

### 2026-09-30 · agent-playbook · `sync.sh` refused git worktrees

It checked `[ -d "$TARGET/.git" ]`, but in a worktree `.git` is a file, so a sync couldn't run from a side checkout that leaves a venture's in-progress branch alone. Touches: `sync.sh`. → resolved: now uses `git rev-parse --is-inside-work-tree` (sync-friction PR).

### 2026-09-30 · smartSportApp · Synced skills reference an `AGENTS.md` section `sync.sh` never delivers

`sync.sh` carries skills, subagents, and rules, but not `AGENTS.md`, which is venture-owned. After #7 the skills point at `AGENTS.md` → *Autonomy inside the box*, which only bootstrapped repos (NOVA) had. SmartSport's section was added by hand in smartSportApp#31. Any future generic constitution section will have the same gap. Options: (a) `sync.sh` prints a warning when a template `AGENTS.md` section heading is missing from the venture's file; (b) move generic rules out of `AGENTS.md` into a synced file (e.g. `.cursor/rules/autonomy.mdc`, always-apply) that `AGENTS.md` points to. Leaning (a): keeps one constitution, costs a few lines of shell. Touches: `sync.sh`, principle 7.

### 2026-09-30 · nova · `/plan NV-2` ran Claude Code's built-in `/plan`, not the skill

The session entered native plan mode (read-only), proposed writing the plan file instead of writing it, and its proposal branched from local `main` (`git switch main && git switch -c …`) even though nova#6 had synced the branch-from-`origin/main` rule. Most likely the skill never loaded: Claude Code's built-in `/plan [description]` took the command, and the agent improvised the ritual from the repo. Touches: skill naming, *principle 3*. → resolved: renamed `/spec` (#17), synced in nova#8 / smartSportApp#35. Watch the first `/spec` run to confirm it loads the skill.

### 2026-09-30 · nova · Answered `## Needs human` still needs a separate fold step

NV-2's questions were answered in comments, but `/spec` (then `/plan`) stops until someone moves the answers into `## Decided`, so a Linear agent or a human has to run an extra step. Proposal for review: when every `## Needs human` item has a human reply in the comments, `/spec` folds them itself (writes `## Decided`, resolves the threads, comments that it folded) and continues. It stops only when something is actually unanswered. Touches: *Tracker rules → Product questions*, `/spec`.

### 2026-09-30 · agent-playbook · Every sync needs hand edits to repo-owned files

Five syncs in a row (#7–#17) needed manual edits to `AGENTS.md`, `plans/README.md`, `docs/coordinator.md`, `CLAUDE.md`, or `SETUP.md`, because `sync.sh` only carries skills/rules/hooks and those files are venture-owned. Extends the Sept 30 `AGENTS.md`-section entry. Proposal for review: `sync.sh` greps the target's repo-owned docs for references the current templates no longer use (retired skill names like `/plan`; template lines whose wording changed) and prints each file:line to hand-edit, so no one has to remember them. Touches: `sync.sh`.

