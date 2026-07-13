# Per-project setup checklist

Run through this once when a project graduates to "can break." Skip layers a project hasn't earned yet (see the maturity ladder in `PLAYBOOK.md`).

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

- [ ] `.cursor/environment.json` runs `git config core.hooksPath .githooks` on install — fresh VMs enable the hook automatically. Add stack-specific install steps there as the project matures.
- [ ] Confirm the agent can `gh pr create` (auth available in the environment).

## Slack + GitHub mobile orchestration

- [ ] Install the **GitHub app for Slack**; subscribe a channel to the repo: `/github subscribe <owner>/<repo> pulls checks`.
- [ ] Install **GitHub mobile**; turn on notifications for review requests + CI.
- [ ] (If using Cursor cloud agents from Slack) connect the Cursor Slack integration so you can launch agents by message.
- [ ] Sanity check the loop: launch a trivial agent task → PR opens → Slack pings → review + merge from phone.

## iOS / Apple projects (Xcode 27+)

Once per machine:

- [ ] Select Xcode 27 under **Xcode → Settings → Locations → Command Line Tools** (older toolchains lack the `agent` tool).
- [ ] Export Apple's seven agent skills and install them where both tools read them:

  ```bash
  xcrun agent skills export --output-dir ~/xcode-skills   # absolute path required
  cp -R ~/xcode-skills/* ~/.claude/skills/                # Claude Code native; Cursor reads it for compatibility
  ```

- [ ] **Xcode → Settings → Intelligence:** turn on "Allow external agents to use Xcode tools."
- [ ] Register the Xcode MCP server in Claude Code: `claude mcp add --transport stdio xcode -- xcrun mcpbridge`

Per iOS repo:

- [ ] Commit a project-scoped `.cursor/mcp.json` so Cursor gets the same tools:

  ```json
  { "mcpServers": { "xcode": { "command": "xcrun", "args": ["mcpbridge"] } } }
  ```

- [ ] Know the constraints: **Xcode must be running with the project open** for `mcpbridge` to connect, and it's **local-only** — cloud agents can't use it, so it backs `[ARTIFACT]` evidence, not `[CI]`.
- [ ] Upgrade gates accordingly: the agent can now build, run tests, drive the simulator, and screenshot it — prefer `[ARTIFACT]` (agent-attached simulator screenshot) over `[MANUAL]` in plan units.
- [ ] Portability rule for Apple's skills: the five knowledge skills (`swiftui-specialist`, `swiftui-whats-new-27`, `test-modernizer`, `uikit-app-modernization`, `c-bounds-safety`) work in any tool; `device-interaction` and `audit-xcode-security-settings` need Xcode's own tools — use those from inside Xcode's agent.
- [ ] Use Xcode's native agent as the specialist surface: SwiftUI preview verification, simulator interaction, and the crash-report-from-Organizer → fix flow. Cursor/Claude Code remain the daily drivers.

## Graduate when ready

- [ ] Dedicated secret scanning in CI (gitleaks) for defense-in-depth beyond push protection.
- [ ] Staging environment: `main` → staging; a tagged `release` → prod.
- [ ] Platform CI (e.g. macOS runners for iOS) once a test target exists.
