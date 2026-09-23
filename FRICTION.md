# Friction log

> Append-only. What was clunky, wrong, or missing when the playbook met reality. Anyone — a Cursor thread, a venture agent, a human — appends here; **only the steward edits doctrine.** Reviewed with the Chief of Staff every two weeks; the steward proposes changes from it, Nathan decides. When an entry is resolved, add a `→ resolved:` line pointing at the PR; don't delete it.
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
