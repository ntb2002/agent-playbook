# Per-project setup checklist

Run through this once when a project graduates to "can break." Skip layers a project hasn't earned yet (see the maturity ladder in `PLAYBOOK.md`).

## The venture cell (once per venture, ~30 min)

A venture is more than its repo. Every venture in the portfolio gets the same small set of homes, so adding venture N never means rebuilding the operating system. One authoritative source per kind of fact — no duplicates.

- [ ] **Repo(s)** — scaffolded by `bootstrap.sh`; `AGENTS.md` owns conventions, `plans/` owns gated specs.
- [ ] **Knowledge hub page** (Notion or equivalent) — thesis, decisions-and-why, thinking docs. Holds *strategy*, never engineering status; it points at the tracker for that. **Execution agents don't read it** — its ideas reach code as tracker issues (drafted by you, a co-founder, or an agent with the Linear connector; approved by you) and the one-page `VISION.md` you curate.
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
- [ ] **Artifacts in PRs:** Dashboard → Cloud Agents → *Allow posting artifacts to GitHub*. On, the agent's screenshots/recordings embed in the PR description via long unguessable **public** URLs (GitHub's image proxy can't read private repos; this is the only way they render inline). Decide per venture: fine for a training app's UI; think twice where screenshots could show a customer's data (e.g. an architect's drawings) — off means you review artifacts in the Cursor agent view instead. Only applies to PRs the cloud agent opened; local-lane evidence follows `plans/README.md` (commit + link + tracker attachment).

## Going live: tracker + coordinator + automations (continuous mode)

Do this when the product has real users or when someone other than you needs to file work. Doctrine: `PLAYBOOK.md` → *Phase mode and continuous mode*.

**Linear (once per workspace, then per venture):**

- [ ] **One workspace for the portfolio; one team per venture** (e.g. `SS`, `NV`), venture-neutral workspace name. Not one workspace per venture: Cursor's Linear integration connects **one Linear workspace per Cursor account** (a second connection disconnects the first), so separate workspaces means only one venture gets issue → Cursor delegation. Route to the right repo with `repo=owner/name` labels on each team's projects (Cursor resolves `[repo=…]` in text → issue label → project label → dashboard default); team-scoped ids (`SS-42`, `NV-7`) carry the venture into branch names and PR titles. Split a venture into its own workspace only when it has its own team and billing. Free tier: unlimited members, 2 teams, 250 non-archived issues workspace-wide (Done/Canceled count until archived — shorten auto-archive in team settings); Basic removes the cap and allows 5 teams.
- [ ] Skip cycles until there are two weeks of velocity to plan against. Use a **project** per body of work (e.g. "Tester-Ready", "MVP").
- [ ] Connect GitHub (Linear settings → Integrations → GitHub): PRs auto-link when the branch name or PR title contains the issue id (`SS-42`); issues move to In Progress on PR open and Done on merge. This closes the loop `/close-unit` used to dead-end at. **Linear Reviews** (sidebar → Reviews) is the same GitHub PRs, in Linear — squash-and-merge from there is a GitHub merge. Merge from Linear *or* GitHub; git still lives on GitHub. Docs-only PRs must not put live issue ids in the title (a mapping table in the body is fine) — Linear will otherwise attach those issues, move them In Progress, and show them as "Resolves".
- [ ] **Use all three states.** Triage = inbox (agents, integrations, non-team members; trend to empty). Backlog = accepted, not scheduled. Todo = the build queue — approved *and* specified; agents pull only from here. Two human clicks: accept out of Triage, promote into Todo. Linear's Triage view has one-key accept / decline / duplicate / snooze for the first click.
- [ ] **Titles name the work.** Id, project, labels, and priority stay as fields. Don't prefix titles with plan-file codes (`TR-00 ·`) or team keys.
- [ ] Issue drafts that need a product call use a `## Needs human` heading. Humans answer in a comment; an agent folds the answers into `## Decided` in the description before the issue is promoted to Todo. Such issues can wait in Backlog. Don't rewrite the whole issue by hand, and don't leave the decision only in a chat prompt.
- [ ] Connect Cursor: cursor.com/dashboard/integrations → Linear → authorize the workspace and team. Then Dashboard → Cloud Agents: set this repo as the default (or add a `repo=owner/name` label per team), confirm GitHub is connected and usage-based pricing is on — delegation won't fire without it. Each human who delegates links their own Cursor account the first time.
- [ ] Add members: co-founders write ideas into **Triage** in plain English — one line, zero ceremony. Anything that needs real thinking gets a knowledge-hub doc the issue links to, so domain work visibly sits upstream of engineering.
- [ ] Let agents work Triage: an agent with the Linear connector (a Claude project, Grok Bot, the Cursor Project coordinator) expands one-liners into draft acceptance criteria, dedupes, labels, and proposes priority. Agents never change status by hand — accepting out of Triage and promoting into Todo are human clicks, even when the agent is talking to you and you've just said "sounds good"; In Progress / Done come from the PR. An agent that thinks issues are ready lists them and asks you to press the key. Keep Triage enabled on every team for this reason.
- [ ] Connect Linear MCP in Cursor/Claude Code so `/plan-feature` fetches the issue itself and agents can file follow-ups and bugs found mid-unit without a human relaying them.
- [ ] Flip the `AGENTS.md` landing pad: *next actionable* points at the tracker view, not a phase file. Remove any engineering status from the venture's knowledge hub page — it points at Linear now.

**Delegating from Linear:** assign an issue to **Cursor** (assignee menu) or `@Cursor <instructions>` in a comment → a cloud agent works the repo and returns a PR, with progress posted back on the issue. Point it at the plan unit and carry the model tier explicitly: `@Cursor build this per plans/features/SS-42-<slug>.md [model=<id>]`. The plan's **Model:** line says which tier; the dashboard default is a fallback, not the mechanism. Good for small, well-specified issues. Cross-cutting or safety-critical work: drive it yourself with the strongest model, or let the coordinator dispatch it with the strong tier.

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
  xcrun agent skills export --output-dir ~/.agents/skills --replace-existing   # absolute path; Cursor reads ~/.agents/skills
  for s in ~/.agents/skills/*/; do n=$(basename "$s"); [ -e ~/.claude/skills/$n ] || ln -s "$s" ~/.claude/skills/$n; done   # Claude Code
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

- [ ] Know the constraints: the tools are **local-only** — cloud agents can't reach them, so they back `[ARTIFACT]` evidence, not `[CI]`. They need either Xcode open on the project, or **headless mode** (Xcode 27+, preview): `sudo xcrun mcp-server enable`, then `sudo xcrun mcp-server allow-folder <repo> --always`. Headless is what lets a Cursor *Remote Control* session on an always-on Mac (clamshell laptop counts) build, test, and drive the simulator from your phone. Never use `--unsafe-always-allow-all-agents`.
- [ ] Know what the tools cover — **verify with `tools/list`, the surface changed a lot between versions.** Xcode 26.x: 21 tools — build, tests, `RenderPreview`, snippets, docs. Xcode 27: 53 tools — adds `RunProject`/`StopProject`/`GetConsoleOutput`, `InvokeDebuggerCommand` (LLDB), `DeviceInteraction*` (boot simulator, install, synthesize taps, screenshot), `GetTopCrashIssues`/`GetCrashIssueLogs`, scheme/destination switching, build settings and entitlements editing, String Catalog tools.
- [ ] Upgrade gates accordingly. On 27+: build/test, preview renders, **and simulator tap-through flows with screenshots** are `[ARTIFACT]` (agent-attached). `[MANUAL]` shrinks to physical-device-only behavior, real payments/push, and subjective feel.
- [ ] Apple's skills (10 on Xcode 27: `swiftui-specialist`, `swiftui-whats-new-27`, `modernize-tests`, `uikit-app-modernization`, `adopt-c-bounds-safety`, `building-document-based-swiftui-applications`, `app-intents-specialist`, `app-intents-whats-new-27`, `device-interaction`, `audit-xcode-security-settings`). The knowledge skills work in any tool; `device-interaction` and `audit-xcode-security-settings` call Xcode MCP tools, so they work from Cursor/Claude Code **only when the Xcode MCP is connected**. Re-export with `--replace-existing` after each Xcode update.
- [ ] Xcode's own agent (plan mode, approve-before-build, ACP so Claude Code can run inside it, plugins that carry skills) is a specialist surface, not the daily driver: reach for it on pure-Swift UI units where you want the native plan/preview canvas. Cursor and Claude Code stay primary so every venture runs the same loop.

## Graduate when ready

- [ ] Dedicated secret scanning in CI (gitleaks) for defense-in-depth beyond push protection.
- [ ] Staging environment: `main` → staging; a tagged `release` → prod.
- [ ] Platform CI (e.g. macOS runners for iOS) once a test target exists.
