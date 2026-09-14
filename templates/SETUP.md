# Per-project setup checklist

Run through this once when a project graduates to "can break." Skip layers a project hasn't earned yet (see the maturity ladder in `PLAYBOOK.md`).

## The venture cell (once per venture, ~30 min)

A venture is more than its repo. Every venture in the portfolio gets the same small set of homes, so adding venture N never means rebuilding the operating system. One authoritative source per kind of fact — no duplicates.

- [ ] **Repo(s)** — scaffolded by `bootstrap.sh`; `AGENTS.md` owns conventions, `plans/` owns gated specs.
- [ ] **Knowledge hub page** (Notion or equivalent) — thesis, decisions-and-why, thinking docs. Holds *strategy*, never engineering status; it points at the tracker for that. **Coding agents don't read it** — its ideas reach code only as acceptance criteria you write into the tracker and the one-page `VISION.md` you curate.
- [ ] **Status row** in the portfolio status database — current state / next action / blockers / last-updated. This is what a daily pull or staleness check reads.
- [ ] **Tracker team** (Linear) — what's next and who's on it. Set up when the product goes live or when anyone other than you needs to file work (a co-founder, a trial engineer). See *Going live* below.
- [ ] **Slack channel** — `#<venture>-dev` (PRs, CI, automation summaries). Subscribe the repo; start with just this one channel.
- [ ] **Coordinator** (Cursor Project) — once in continuous mode. One per repo. See *Going live*.
- [ ] Dormant ventures get only the first three. Don't build the rest until there's code.

## Local (per clone / per machine)

- [ ] `git config core.hooksPath .githooks` — enable the pre-commit hook (secret-scan + lint/test). Bootstrap sets this automatically; cloud VMs use `.cursor/environment.json`.
- [ ] Confirm the hook fires: a commit with a fake `sk-ant-…` or `sk-proj-…` string in a staged file should be blocked. If `gitleaks` is installed locally, the hook uses it automatically.

## GitHub (once per repo)

- [ ] Push the repo to GitHub; confirm CI runs on the first PR.
- [ ] **Settings → Branches → Add ruleset** for `main`: require a PR, require the CI status check, require up-to-date branches.
  - ⚠️ **Free + private repo:** GitHub won't *enforce* rulesets (wants Team/Pro). Not a blocker — CI still runs and shows on every PR; you keep the branch→PR→merge discipline, you just lose the hard block. For free hard enforcement, **make the repo public** (also good for a portfolio); or **GitHub Pro** (~$4/mo) protects private branches. Defer until others can merge or real users exist.
- [ ] **Settings → Code security:** enable Secret scanning + Push protection.
- [ ] (Real users) Add a bot reviewer — Cursor Bugbot or CodeRabbit — on PRs.

## Cloud agents (Cursor / Claude Code)

- [ ] `.cursor/environment.json` runs `git config core.hooksPath .githooks` on install — fresh VMs enable the hook automatically. Add stack-specific install steps there as the project matures: the `install` step is what Cursor's *Builds* pre-bake, so anything preparable ahead of time (dependency install, hook enable) belongs in `install`, and only things that must be fresh per session belong in `start`. Enable Builds in Dashboard → Cloud Agents → the environment → Builds tab.
- [ ] Confirm the agent can `gh pr create` (auth available in the environment).
- [ ] `.cursor/hooks.json` fires in cloud agents too — confirm the commit guard blocks a `git commit` on `main` from a cloud run once.

## Going live: tracker + coordinator + automations (continuous mode)

Do this when the product has real users or when someone other than you needs to file work. Doctrine: `PLAYBOOK.md` → *Phase mode and continuous mode*.

**Linear (once per workspace, then per venture):**

- [ ] One workspace for the portfolio; one **team** per venture (e.g. `SS`, `NV`). Free tier: unlimited members, 250 active issues — plenty.
- [ ] Skip cycles until there are two weeks of velocity to plan against. Use a **project** per body of work (e.g. "Tester-Ready", "MVP").
- [ ] Connect GitHub (Linear settings → Integrations → GitHub): PRs auto-link when the branch name or PR title contains the issue id (`SS-42`); issues move to In Progress on PR open and Done on merge. This closes the loop `/close-unit` used to dead-end at.
- [ ] Connect Cursor: cursor.com/dashboard/integrations → Linear → authorize the workspace and team. Then Dashboard → Cloud Agents: set this repo as the default (or add a `repo=owner/name` label per team), confirm GitHub is connected and usage-based pricing is on — delegation won't fire without it. Each human who delegates links their own Cursor account the first time.
- [ ] Add members: co-founders write ideas into **triage** in plain English — one line, zero ceremony. You translate to acceptance criteria at prioritization. Anything that needs real thinking gets a knowledge-hub doc the issue links to, so domain work visibly sits upstream of engineering.
- [ ] Optional: Linear MCP in Cursor/Claude Code so `/plan-feature` can fetch the issue itself.
- [ ] Flip the `AGENTS.md` landing pad: *next actionable* points at the tracker view, not a phase file. Remove any engineering status from the venture's knowledge hub page — it points at Linear now.

**Delegating from Linear:** assign an issue to **Cursor** (assignee menu) or `@Cursor <instructions>` in a comment → a cloud agent works the repo and returns a PR, with progress posted back on the issue. Good for small, well-specified issues. Cross-cutting or safety-critical work: drive it yourself with the strongest model.

**Cursor Project — the coordinator (one per repo):**

- [ ] Create a Project (Cursor left nav → Projects). Name it for the body of work (e.g. `<Venture> — engineering`).
- [ ] First message: point it at `AGENTS.md`, `PLAYBOOK.md`'s coordinator rules, and `docs/coordinator.md` in this repo. Tell it to run the loop in that brief and nothing else.
- [ ] Subscriptions: its own PRs (default — it fixes CI and addresses bot comments); Linear *status → Ready* (or whichever status means "approved to build"). Optionally the venture's Slack channel for bug reports.
- [ ] Review **every** PR it produces for the first two weeks. Add an issue class to *Delegated approval* in `docs/coordinator.md` only after it has produced several clean PRs of that class. Remove it the first time one is wrong.
- [ ] Watch the usage meter for the first week — Projects run on cloud-agent allowance and pricing is still settling (beta).
- [ ] Rule: one coordinator per repo. A personal ops agent (Grok Bot) files a Linear issue; it does not dispatch coding agents at this repo directly.

**Automations (dashboard → Automations, or `/automate` in Cursor):**

- [ ] `pr-review` — trigger *PR opened*; prompt from `.cursor/automations/pr-review.md`. Post to the venture's Slack channel. Start here; it's the read-only `code-review` subagent running without you.
- [ ] Add *CI failure triage* and *autofix review comments* only after `pr-review` has earned trust (see the bottom of that file).
- [ ] A scheduled *staleness check* is the repo-side half of "notice when something stops." Pair it with a knowledge-layer check on the portfolio status database.

**Supervisor (optional, Grok Bot or equivalent):** give it one job first — watch this repo's PRs, confirm every `[ARTIFACT]` gate has a real attachment, and message you when a PR is ready or when the evidence doesn't match the claim. Its memory is account-bound; anything durable it learns goes to the repo or the knowledge hub.

## Phone orchestration (Slack + GitHub mobile + Cursor iOS)

- [ ] Install the **GitHub app for Slack**; subscribe a channel to the repo: `/github subscribe <owner>/<repo> pulls checks`.
- [ ] Install **GitHub mobile**; turn on notifications for review requests + CI.
- [ ] Install **Cursor for iOS** (paid plan): launch cloud agents, watch them, review diffs/artifacts, merge. Turn on notifications so "ready for review" reaches your lock screen. For a laptop agent you want to keep steering from your phone: Settings → Agents → Remote Control, then `/remote-control` in that agent.
- [ ] (If using Cursor cloud agents from Slack) connect the Cursor Slack integration so you can launch agents by message.
- [ ] Sanity check the loop: launch a trivial agent task → PR opens → Slack pings → review + merge from phone.

## iOS / Apple projects (Xcode 27+)

Once per machine:

- [ ] Select Xcode 27 under **Xcode → Settings → Locations → Command Line Tools** (older toolchains lack the `agent` tool). The MCP server itself works from Xcode 26.3+; only the skills need 27.
- [ ] Export Apple's seven agent skills and install them where both tools read them:

  ```bash
  xcrun agent skills export --output-dir ~/xcode-skills   # absolute path required
  cp -R ~/xcode-skills/* ~/.claude/skills/                # Claude Code native; Cursor reads it for compatibility
  ```

  On Xcode 26.x the equivalent command (`xcrun mcpbridge run-agent skills export`) exists but reports "No skills available to export" — the bundles ship with 27.

- [ ] **Xcode → Settings → Intelligence:** turn on "Allow external agents to use Xcode tools."
- [ ] Register the Xcode MCP server in Claude Code: `claude mcp add --transport stdio xcode -- xcrun mcpbridge`

Per iOS repo (new repos: `bootstrap.sh <dir> "<Name>" "<one-liner>" --ios` does the first two automatically):

- [ ] Commit a project-scoped `.cursor/mcp.json` so Cursor gets the same tools:

  ```json
  { "mcpServers": { "xcode": { "command": "xcrun", "args": ["mcpbridge"] } } }
  ```

- [ ] Add the iOS agent conventions to `AGENTS.md` (verify via Xcode MCP before claiming done; preview snapshots as `[ARTIFACT]`) — see `overlays/ios/AGENTS-ios.md` in the playbook.

- [ ] Know the constraints: **Xcode must be running with the project open** for `mcpbridge` to connect, and it's **local-only** — cloud agents can't use it, so it backs `[ARTIFACT]` evidence, not `[CI]`. (Cursor's *self-hosted machines* can register a Mac as a cloud-agent worker; that's the path to cloud agents producing iOS build/test/preview evidence — worth it once a Mac is always on.)
- [ ] Know what the tools actually cover: build, run tests, search Apple docs, and `RenderPreview` (renders a specific `#Preview` block to a real image, with dark-mode / orientation / type-size variants). **No live-simulator interaction and no LLDB/debugger tool** — tap-through flows and arbitrary in-app state stay `[MANUAL]`.
- [ ] Upgrade gates accordingly: build/test results and preview-renderable UI become `[ARTIFACT]` (agent-attached); leave genuinely interactive verification as `[MANUAL]`.
- [ ] Portability rule for Apple's skills: the five knowledge skills (`swiftui-specialist`, `swiftui-whats-new-27`, `test-modernizer`, `uikit-app-modernization`, `c-bounds-safety`) work in any tool; `device-interaction` and `audit-xcode-security-settings` need Xcode's own tools — use those from inside Xcode's agent.
- [ ] Use Xcode's native agent as the specialist surface: SwiftUI preview verification, simulator interaction, and the crash-report-from-Organizer → fix flow. Cursor/Claude Code remain the daily drivers.

## Graduate when ready

- [ ] Dedicated secret scanning in CI (gitleaks) for defense-in-depth beyond push protection.
- [ ] Staging environment: `main` → staging; a tagged `release` → prod.
- [ ] Platform CI (e.g. macOS runners for iOS) once a test target exists.
